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

variable "deployment_env" {
    description = "environment flag so that features can be disabled/enabled in certain environments"
    default = "vagov-dev"
}

variable "gibct_url" {
    description = "Link to GIBCT (vets-api) service that requests data from GIDS. Should point to instance of GIBCT running in same env"
    default = "https://dev.va.gov/gi-bill-comparison-tool"
}

variable "govdelivery_staging_service" {
    description = "True or False"
    default = "True"
}

variable "govdelivery_url" {
    description = "URL with which we send devise emails"
    default = "stage-tms.govdelivery.com"
}

variable "link_host" {
    description = "??? seems to be respective vets-api instance, but dev/staging vals are wrong"
    default = "https://staging-platform-api.va.gov"
}

variable "sandbox_url" {
    description = "same as GIBCT url, but points to sandbox"
    default = "https://staging.va.gov/gi-bill-comparison-tool-sandbox"
}

variable "ps_prefix" {
  description = "prefix used in parameter store: dev/staging/prod"
  default = "dev"
}
