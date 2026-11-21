locals {
  name = "uipath-${var.environment}"
}

module "network" {
  source = "../modules/network"

  name                       = local.name
  region                     = var.region
  vpc_cidr                   = var.vpc_cidr
  az_count                   = 3
  enable_nat_gateway         = var.enable_nat_gateway
  enable_interface_endpoints = var.enable_interface_endpoints
}

# The secret value is set with the AWS CLI, so it never appears in code or state.
data "aws_secretsmanager_secret" "orchestrator" {
  name = var.orchestrator_secret_name
}

module "robots" {
  source = "../modules/robots"

  name                    = local.name
  region                  = var.region
  vpc_id                  = module.network.vpc_id
  subnet_ids              = module.network.private_subnet_ids
  internet_egress_enabled = var.enable_nat_gateway
  orchestrator_secret_arn = data.aws_secretsmanager_secret.orchestrator.arn
  instance_type           = var.robot_instance_type
  robot_count             = var.robot_count
}
