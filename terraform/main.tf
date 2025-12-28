module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.20.0"

  cluster_name    = "eks-devops"
  cluster_version = "1.30"

  # 👇 ESSA É A LINHA QUE RESOLVE SEU ERRO DO apply
  manage_aws_auth_configmap = false

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      desired_size  = 3
      max_size      = 3
      min_size      = 3
      # t3.small é Free Tier elegível e adequado para EKS
      # Se você quiser usar t3.medium, precisa remover a restrição de Free Tier na conta AWS
      instance_types = ["t3.small"]
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}
