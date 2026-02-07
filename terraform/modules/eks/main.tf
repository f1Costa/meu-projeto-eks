module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  create_kms_key = var.create_kms_key

  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = var.kms_key_arn
  }

  manage_aws_auth_configmap = var.manage_aws_auth_configmap

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  eks_managed_node_groups = var.node_groups

  tags = var.tags
}
