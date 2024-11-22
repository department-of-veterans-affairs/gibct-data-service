terraform {
  # Required Terraform Version
  required_version = ">= 0.13.2"

  # Terraform State Storage
  backend "s3" {
    bucket         = "prt-global-prod-tf-state"
    key            = "gi-bill/fargate/terraform.tfstate"
    region         = "us-gov-west-1"
    encrypt        = true
    dynamodb_table = "prt-global-prod-tf-state-lock"
  }

  # Providers Versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}


# AWS Provider
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      deployed_from = "department-of-veterans-affairs/${local.name}"
      state_bucket  = "prt-global-prod-tf-state"
      state_key     = "${local.name}/prod-fargate/terraform.tfstate"
      state_table   = "prt-global-prod-tf-state-lock"
      office        = "osva"
      suboffice     = "cto"
      group         = "dsva"
      application   = "${local.name}"
      provider      = "aws"
      repo          = "${local.name}"
      repo_ref      = "main"
      repo_sha      = "tbd"
    }
  }
}