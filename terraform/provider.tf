terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"   # 👈 FIXANDO EM 5.x
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
  required_version = ">= 1.6.0"
}

provider "aws" {
  region = "us-east-1"
}

# Data source para obter informações do cluster EKS
data "aws_eks_cluster" "this" {
  name = "eks-devops"
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name = "eks-devops"
  depends_on = [module.eks]
}

# Provider Kubernetes configurado dinamicamente após o cluster ser criado
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}


