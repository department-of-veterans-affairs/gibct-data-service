variable "environment" {
  default = "dsva-vagov"
  type    = string
}

variable "project" {
  default = "gibct"
  type    = string
}

variable "app_version" {
  default = "latest"
  type    = string
}

variable "vpc" {
  default = "dsva-vagov-dev-vpc"
  type    = string
}

variable "vpc_subnets" {
  default = [
    "dsva-vagov-dev-subnet-1a",
    "dsva-vagov-dev-subnet-1b",
    "dsva-vagov-dev-subnet-1c",
  ]
}

variable "region" {
  type    = string
  default = "us-gov-west-1"
}

variable "fargate_count" {
    description = "Fargate instance count"
    default = "3"
}

variable "fargate_cpu" {
    description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
    default = "2048"
}

variable "fargate_memory" {
    description = "Fargate instance memory to provision (in MiB)"
    default = "4096"
}
