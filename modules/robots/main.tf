# Unattended UiPath robots on Windows EC2, in private subnets.
# - No inbound rule, no public IP, no RDP: administration through SSM Session Manager.
# - IMDSv2 only, encrypted root volume.
# - Orchestrator credentials read at boot from Secrets Manager by the instance role.
# - Auto Scaling group from 0 to max_robots; queue-driven scaling comes in a later step.

data "aws_default_tags" "current" {}

data "aws_ssm_parameter" "windows_ami" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

# ---------------------------------------------------------------- Network access

resource "aws_security_group" "robot" {
  name        = "${var.name}-robot"
  description = "UiPath robots: outbound only"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name}-robot" }
}

resource "aws_vpc_security_group_egress_rule" "robot_https" {
  security_group_id = aws_security_group.robot.id
  description       = "HTTPS: UiPath Automation Cloud, AWS APIs, installer download"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "robot_http" {
  security_group_id = aws_security_group.robot.id
  description       = "HTTP: certificate revocation checks (CRL/OCSP)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# ---------------------------------------------------------------- Instance role

resource "aws_iam_role" "robot" {
  name = "${var.name}-robot"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Session Manager, Run Command and Patch Manager.
resource "aws_iam_role_policy_attachment" "robot_ssm" {
  role       = aws_iam_role.robot.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Read only the Orchestrator secret, nothing else.
resource "aws_iam_role_policy" "robot_secret" {
  name = "read-orchestrator-secret"
  role = aws_iam_role.robot.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = var.orchestrator_secret_arn
    }]
  })
}

resource "aws_iam_instance_profile" "robot" {
  name = "${var.name}-robot"
  role = aws_iam_role.robot.name
}

# ---------------------------------------------------------------- Launch template

resource "aws_launch_template" "robot" {
  name_prefix            = "${var.name}-robot-"
  image_id               = data.aws_ssm_parameter.windows_ami.insecure_value
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.robot.id]
  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.robot.arn
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.root_volume_gb
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/user_data.ps1.tftpl", {
    secret_arn    = var.orchestrator_secret_arn
    region        = var.region
    installer_url = var.installer_url
  }))

  # Default tags do not reach instances launched by an Auto Scaling group.
  tag_specifications {
    resource_type = "instance"
    tags          = merge(data.aws_default_tags.current.tags, { Name = "${var.name}-robot", Role = "uipath-robot" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(data.aws_default_tags.current.tags, { Name = "${var.name}-robot", Role = "uipath-robot" })
  }
}

# ---------------------------------------------------------------- Auto Scaling group

resource "aws_autoscaling_group" "robot" {
  name                = "${var.name}-robots"
  min_size            = 0
  max_size            = var.max_robots
  desired_capacity    = var.robot_count
  vpc_zone_identifier = var.subnet_ids
  health_check_type   = "EC2"

  # Pin the exact version: with "$Latest" Terraform sees no change on the group and the
  # instance refresh below is never triggered.
  launch_template {
    id      = aws_launch_template.robot.id
    version = aws_launch_template.robot.latest_version
  }

  # A new launch template version (AMI, bootstrap script) replaces the robots automatically.
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 0
    }
  }

  lifecycle {
    # A robot without a route to the internet can never reach Orchestrator.
    precondition {
      condition     = var.robot_count == 0 || var.internet_egress_enabled
      error_message = "robot_count > 0 requires enable_nat_gateway = true (robots must reach UiPath Automation Cloud)."
    }
  }
}
