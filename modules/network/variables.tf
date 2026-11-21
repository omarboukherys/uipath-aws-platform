variable "name" {
  description = "Prefix used in resource names."
  type        = string
}

variable "region" {
  description = "AWS region (used to build VPC endpoint service names)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to spread the subnets across."
  type        = number
  default     = 3
}

variable "enable_nat_gateway" {
  description = "Create a single NAT Gateway so private subnets reach the internet (UiPath Automation Cloud, Windows updates). Billed per hour: enable only during working sessions."
  type        = bool
  default     = false
}

variable "enable_interface_endpoints" {
  description = "Create SSM interface endpoints so instances are managed without internet access. Billed per hour and per AZ."
  type        = bool
  default     = false
}

variable "interface_endpoint_az_count" {
  description = "Number of AZs that receive the interface endpoints (1 keeps the lab cheap, use az_count in production)."
  type        = number
  default     = 1
}

variable "enable_flow_logs" {
  description = "Send VPC flow logs to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Retention of the flow logs."
  type        = number
  default     = 7
}
