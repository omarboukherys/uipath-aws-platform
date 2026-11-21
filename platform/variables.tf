variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Turn on during working sessions only (billed per hour)."
  type        = bool
  default     = false
}

variable "enable_interface_endpoints" {
  description = "SSM interface endpoints (billed per hour and per AZ)."
  type        = bool
  default     = false
}

variable "robot_count" {
  description = "Number of robot VMs. Keep 0 outside working sessions."
  type        = number
  default     = 0
}

variable "robot_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "orchestrator_secret_name" {
  description = "Secrets Manager secret created out of band (never stored in Terraform state)."
  type        = string
  default     = "uipath/robot-machine-template"
}
