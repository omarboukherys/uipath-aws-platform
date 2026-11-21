terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Partial configuration: values come from backend.hcl (see backend.hcl.example).
  # use_lockfile = native S3 state locking, no DynamoDB table needed.
  backend "s3" {}
}
