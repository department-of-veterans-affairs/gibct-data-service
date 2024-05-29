locals {
  eks_oidc_issuer = trimprefix(module.eks_cluster.eks_cluster_identity_oidc_issuer, "https://")
}

resource "aws_iam_role" "app_role" {
  name               = "${var.eks_cluster_name}-${var.env_name}"
  assume_role_policy = data.aws_iam_policy_document.AssumeRole.json
  inline_policy {
    name   = "policy-${var.eks_cluster_name}-${var.env_name}"
    policy = data.aws_iam_policy_document.inline.json
  }
}

# TODO
data "aws_iam_policy_document" "AssumeRole" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        "arn:aws-us-gov:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer}"
      ]
    }

    # Limit the scope so that only our desired service account can assume this role
    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer}:sub"
      values = [
        "system:serviceaccount:${var.env_name}:vets-api"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer}:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }

  }
}

data "aws_iam_policy_document" "inline" {
  statement {
    effect = "Allow"
    actions = [
      "*"
    ]
    resources = [
      aws_rds_cluster.this.arn,
      aws_rds_cluster_instance.this.arn,
    ]
  }
}
