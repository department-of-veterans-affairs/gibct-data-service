locals {
  name = "${var.environment}-${var.project}-${terraform.workspace}"
}

output "workspace" {
    value = terraform.workspace
}

output "name" {
    value = local.name
}

