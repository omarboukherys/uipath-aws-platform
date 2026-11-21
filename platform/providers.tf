provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "uipath-aws-platform"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
