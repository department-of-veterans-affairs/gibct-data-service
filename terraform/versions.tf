terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.23.0"
    }
  }
}