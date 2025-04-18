provider "aws" {
  region = "us-gov-west-1"
}

provider "kubernetes" {

}

provider "helm" {

}


# TODO Why not require the tools vs require as a provider?
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
  }

  required_version = "~> 1.0"
}