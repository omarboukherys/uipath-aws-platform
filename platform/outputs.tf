output "vpc_id" {
  value = module.network.vpc_id
}

output "azs" {
  value = module.network.azs
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "data_subnet_ids" {
  value = module.network.data_subnet_ids
}

output "robots_autoscaling_group" {
  value = module.robots.autoscaling_group_name
}
