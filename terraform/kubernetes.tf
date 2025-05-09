resource "kubernetes_namespace" "this" {
  metadata {
    name = var.env_name
  }
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = "vets-api"
    namespace = kubernetes_namespace.this.metadata.0.name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.app_role.arn
    }
  }
}