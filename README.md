# Projeto EKS - DevOps

Projeto para deploy de aplicação Python em cluster EKS na AWS usando Terraform.

## Estrutura do Projeto

- `terraform/` - Configurações do Terraform para criar o cluster EKS
- `app/` - Aplicação Python
- `k8s/` - Manifests Kubernetes
- `Dockerfile` - Imagem Docker da aplicação

## Permissões IAM

As permissões IAM necessárias estão configuradas na role `GitHubActionsEKSRole` e incluem:
- CloudWatch Logs
- IAM (inline e managed policies)
- EC2 (incluindo tags e modificação de atributos VPC)
- EKS
- ELB
- KMS (para criptografia do cluster)

## Deploy

O deploy é feito automaticamente via GitHub Actions quando há push para a branch `main`.

## Status

Pipeline configurado com todas as permissões IAM necessárias, incluindo:
- IAM managed policies (CreatePolicy, DeletePolicy, etc.)
- EC2 EIP e Security Group Rules
- CloudWatch Logs completo

