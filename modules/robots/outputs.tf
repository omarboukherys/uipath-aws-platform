output "autoscaling_group_name" {
  value = aws_autoscaling_group.robot.name
}

output "security_group_id" {
  value = aws_security_group.robot.id
}

output "instance_role_name" {
  value = aws_iam_role.robot.name
}
