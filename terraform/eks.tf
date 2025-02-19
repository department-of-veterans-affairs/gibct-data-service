module "eks_cluster" {
  source = "git::ssh://git@github.com/department-of-veterans-affairs/vsp-platform-infrastructure.git//terraform/modules/eks-cluster?ref=eks-cluster-v0.1.2"

  vpc_id             = module.join_existing_network.vpc.id
  subnet_ids         = module.join_existing_network.subnets.ids
  kubernetes_version = var.kubernetes_version

  context = module.context.context
}
