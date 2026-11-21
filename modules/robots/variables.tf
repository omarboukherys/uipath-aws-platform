variable "name" {
  description = "Prefix used in resource names."
  type        = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Private subnets that host the robots."
  type        = list(string)
}

variable "internet_egress_enabled" {
  description = "True when the private subnets have a route to the internet (NAT). Robots need it to reach UiPath Automation Cloud."
  type        = bool
}

variable "orchestrator_secret_arn" {
  description = "Secrets Manager secret with orchestrator_url, client_id and client_secret of the machine template."
  type        = string
}

variable "installer_url" {
  description = "UiPath Platform Installer (Community channel for a Community organization)."
  type        = string
  default     = "https://download.uipath.com/connected-installer/latest/community/UiPathPlatform.msi"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "root_volume_gb" {
  type    = number
  default = 50
}

variable "robot_count" {
  description = "Desired number of robot VMs. 0 = nothing runs, nothing is billed for compute."
  type        = number
  default     = 0
}

variable "max_robots" {
  type    = number
  default = 2
}
