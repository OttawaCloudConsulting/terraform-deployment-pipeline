terraform {
  required_version = "~>1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  # backend "s3" {
  #   bucket = ""
  #   key    = ""
  #   acl    = "bucket-owner-full-control"
  #   region = ""
  # }
}

provider "aws" {
  region              = var.provider_variables.region
  allowed_account_ids = ["${var.provider_variables.aws_account_id}"]
  default_tags {
    tags = {
      owner          = var.standard_tags.owner
      classification = var.standard_tags.classification
      solution       = var.standard_tags.solution
      deployment     = var.standard_tags.deployment
      category       = var.standard_tags.category
    }
  }
}