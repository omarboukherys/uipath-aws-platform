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
