<div align="center">

# EKS DevOps Platform

**Plataforma de deploy automatizado de aplicações containerizadas em Amazon EKS com infraestrutura gerenciada por Terraform e CI/CD via GitHub Actions.**

[![Terraform](https://img.shields.io/badge/Terraform-1.6+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.30-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![AWS EKS](https://img.shields.io/badge/AWS-EKS-FF9900?logo=amazoneks&logoColor=white)](https://aws.amazon.com/eks/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![Docker](https://img.shields.io/badge/Docker-Hub-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## Sumario

- [Visao Geral](#visao-geral)
- [Arquitetura](#arquitetura)
- [Tecnologias](#tecnologias)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Pre-requisitos](#pre-requisitos)
- [Configuracao da Infraestrutura](#configuracao-da-infraestrutura)
- [Pipeline CI/CD](#pipeline-cicd)
- [Deploy da Aplicacao](#deploy-da-aplicacao)
- [Acesso ao Cluster](#acesso-ao-cluster)
- [Seguranca](#seguranca)
- [Variaveis Terraform](#variaveis-terraform)
- [Outputs Terraform](#outputs-terraform)

---

## Visao Geral

Este projeto implementa uma plataforma completa de **Infrastructure as Code (IaC)** para provisionamento e operacao de um cluster **Amazon EKS** na AWS. A solucao abrange desde a criacao da rede (VPC) ate o deploy automatizado de aplicacoes containerizadas, seguindo as melhores praticas de DevOps e Cloud Engineering.

### Destaques

- **Infraestrutura 100% como codigo** com Terraform modularizado
- **CI/CD completo** com GitHub Actions e autenticacao OIDC (sem chaves estaticas)
- **Rede multi-AZ** com subnets publicas e privadas em 3 zonas de disponibilidade
- **Criptografia at-rest** de secrets do Kubernetes via AWS KMS
- **Estado remoto** do Terraform em S3 para colaboracao em equipe
- **Deploy automatizado** a cada push na branch `main`

---

## Arquitetura

```
                         ┌──────────────────────────────────────────────┐
                         │              GitHub Actions                  │
                         │  ┌─────────┐  ┌──────────┐  ┌───────────┐  │
                         │  │  Build   │→ │  Push    │→ │  Deploy   │  │
                         │  │  Docker  │  │  Docker  │  │  Terraform│  │
                         │  │  Image   │  │  Hub     │  │  + kubectl│  │
                         │  └─────────┘  └──────────┘  └───────────┘  │
                         └──────────────────────┬───────────────────────┘
                                                │ OIDC Auth
                                                ▼
┌───────────────────────────────────── AWS Account ─────────────────────────────────────┐
│                                                                                       │
│   ┌─────────────────────────── VPC 10.0.0.0/16 ───────────────────────────┐           │
│   │                                                                       │           │
│   │   ┌── Public Subnets ──────────────────────────────────────────┐      │           │
│   │   │  10.0.101.0/24  │  10.0.102.0/24  │  10.0.103.0/24       │      │           │
│   │   │     (AZ-1a)     │     (AZ-1b)     │     (AZ-1c)          │      │           │
│   │   │              ┌──────────────────┐                         │      │           │
│   │   │              │  Load Balancer   │ ← Internet              │      │           │
│   │   │              └────────┬─────────┘                         │      │           │
│   │   └───────────────────────┼───────────────────────────────────┘      │           │
│   │                    NAT GW │                                          │           │
│   │   ┌── Private Subnets ────┼───────────────────────────────────┐      │           │
│   │   │  10.0.1.0/24  │  10.0.2.0/24  │  10.0.3.0/24            │      │  ┌─────┐  │
│   │   │    (AZ-1a)    │    (AZ-1b)    │    (AZ-1c)              │      │  │ KMS │  │
│   │   │           ┌────────────────────────────┐                 │      │  └─────┘  │
│   │   │           │      EKS Cluster v1.30     │                 │      │           │
│   │   │           │  ┌──────┐ ┌──────┐ ┌──────┐│                 │      │  ┌─────┐  │
│   │   │           │  │ Node │ │ Node │ │ Node ││                 │      │  │ S3  │  │
│   │   │           │  │t3.sm │ │t3.sm │ │t3.sm ││                 │      │  │State│  │
│   │   │           │  │ Pod  │ │ Pod  │ │      ││                 │      │  └─────┘  │
│   │   │           │  └──────┘ └──────┘ └──────┘│                 │      │           │
│   │   │           └────────────────────────────┘                 │      │           │
│   │   └──────────────────────────────────────────────────────────┘      │           │
│   └───────────────────────────────────────────────────────────────────────┘           │
│                                                                                       │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Tecnologias

| Categoria | Tecnologia | Finalidade |
|:--|:--|:--|
| **IaC** | Terraform ~> 1.6 | Provisionamento de infraestrutura |
| **Cloud** | AWS (EKS, VPC, IAM, KMS, S3) | Plataforma de nuvem |
| **Orquestracao** | Kubernetes 1.30 | Gerenciamento de containers |
| **Container** | Docker + Docker Hub | Build e registro de imagens |
| **CI/CD** | GitHub Actions | Pipeline automatizado |
| **Aplicacao** | Python 3.11 + FastAPI | API REST |
| **Servidor** | Uvicorn (ASGI) | Servidor de aplicacao |
| **Modulos TF** | terraform-aws-modules/vpc 5.5 | Provisionamento de VPC |
| **Modulos TF** | terraform-aws-modules/eks 19.20 | Provisionamento de EKS |

---

## Estrutura do Projeto

```
.
├── .github/
│   └── workflows/
│       └── pipeline.yml            # Pipeline CI/CD (GitHub Actions)
│
├── terraform/
│   ├── modules/
│   │   ├── vpc/
│   │   │   ├── main.tf             # VPC, Subnets, NAT GW, Internet GW
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── eks/
│   │       ├── main.tf             # Cluster EKS, Node Groups, OIDC
│   │       ├── variables.tf
│   │       └── outputs.tf
│   ├── main.tf                     # Modulo raiz - orquestra VPC + EKS
│   ├── provider.tf                 # Providers AWS e Kubernetes
│   ├── variables.tf                # Variaveis globais
│   ├── outputs.tf                  # Outputs da infraestrutura
│   └── backend.tf                  # Backend remoto (S3)
│
├── k8s/
│   ├── deployment.yaml             # Deployment (2 replicas)
│   └── service.yaml                # Service (LoadBalancer)
│
├── app/
│   ├── main.py                     # API FastAPI
│   └── requirements.txt            # Dependencias Python
│
├── Dockerfile                      # Imagem Docker (Python 3.11-slim)
├── .gitignore
└── README.md
```

---

## Pre-requisitos

| Ferramenta | Versao Minima | Instalacao |
|:--|:--|:--|
| AWS CLI | v2 | [Guia oficial](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| Terraform | 1.6+ | [Download](https://developer.hashicorp.com/terraform/downloads) |
| kubectl | compativel com 1.30 | [Instalacao](https://kubernetes.io/docs/tasks/tools/) |
| Docker | 20.10+ | [Get Docker](https://docs.docker.com/get-docker/) |

Alem disso, e necessario:

- Conta AWS com permissoes adequadas
- Repositorio GitHub com OIDC configurado para AWS
- Conta Docker Hub com token de acesso
- Bucket S3 para estado remoto do Terraform

---

## Configuracao da Infraestrutura

### Modulo VPC

Provisiona a rede completa com isolamento de camadas:

| Recurso | Especificacao |
|:--|:--|
| VPC CIDR | `10.0.0.0/16` |
| Availability Zones | `us-east-1a`, `us-east-1b`, `us-east-1c` |
| Subnets Privadas | `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24` |
| Subnets Publicas | `10.0.101.0/24`, `10.0.102.0/24`, `10.0.103.0/24` |
| NAT Gateway | Single (otimizado para custo) |
| DNS Support | Habilitado |

As subnets possuem tags Kubernetes para auto-discovery pelo ELB controller (`kubernetes.io/role/elb` e `kubernetes.io/role/internal-elb`).

### Modulo EKS

Provisiona o cluster Kubernetes gerenciado:

| Recurso | Especificacao |
|:--|:--|
| Cluster Name | `eks-devops` |
| Kubernetes Version | `1.30` |
| Endpoint Publico | Habilitado |
| Endpoint Privado | Habilitado |
| Node Group | 3x `t3.small` (managed) |
| Criptografia | KMS (secrets at-rest) |
| OIDC Provider | Habilitado (IRSA-ready) |

### Provisionamento Manual

```bash
# Inicializar Terraform
cd terraform
terraform init

# Verificar o plano de execucao
terraform plan

# Aplicar a infraestrutura
terraform apply
```

---

## Pipeline CI/CD

O pipeline e acionado automaticamente a cada push na branch `main` e executa o fluxo completo de build e deploy.

```
 Push (main)
     │
     ▼
 ┌─ Checkout ─────────────────────────────────────┐
 │                                                 │
 │  1. Autenticar na AWS (OIDC)                    │
 │  2. Login no Docker Hub                         │
 │  3. Build da imagem Docker                      │
 │  4. Push para Docker Hub                        │
 │  5. Terraform Init + Apply                      │
 │  6. Configurar kubectl                          │
 │  7. Aguardar cluster ready                      │
 │  8. Deploy manifests Kubernetes                 │
 │                                                 │
 └─────────────────────────────────────────────────┘
```

### Secrets Necessarios no GitHub

| Secret | Descricao |
|:--|:--|
| `DOCKERHUB_TOKEN` | Token de acesso ao Docker Hub |

> A autenticacao AWS utiliza **OIDC Federation** com a role `GitHubActionsEKSRole`, eliminando a necessidade de access keys estaticas.

---

## Deploy da Aplicacao

A aplicacao e uma API REST construida com FastAPI, servida pelo Uvicorn:

```python
# app/main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message": "API rodando no EKS!"}
```

### Especificacoes do Deploy Kubernetes

| Parametro | Valor |
|:--|:--|
| Replicas | 2 |
| Imagem | `felipec23/api-eks:latest` |
| Porta do Container | 5000 |
| Tipo de Service | LoadBalancer |
| Porta Externa | 80 |

O Service do tipo `LoadBalancer` provisiona automaticamente um **Network Load Balancer** na AWS, expondo a aplicacao na porta 80.

---

## Acesso ao Cluster

### Configurar kubeconfig Local

```bash
aws eks update-kubeconfig --region us-east-1 --name eks-devops
```

### Verificar Conectividade

```bash
# Status dos nodes
kubectl get nodes

# Pods em execucao
kubectl get pods

# Services e endpoints
kubectl get svc
```

---

## Seguranca

| Controle | Implementacao |
|:--|:--|
| **Autenticacao CI/CD** | GitHub OIDC Federation (credenciais temporarias) |
| **Criptografia** | KMS para secrets do Kubernetes at-rest |
| **Rede** | Nodes em subnets privadas, LB em subnets publicas |
| **Estado Terraform** | Armazenado em S3 (acesso controlado por IAM) |
| **Kubernetes Auth** | Exec-based auth via `aws eks get-token` |
| **IRSA** | OIDC Provider habilitado para IAM Roles for Service Accounts |
| **Endpoint** | API server com acesso publico + privado |

### Permissoes IAM (GitHubActionsEKSRole)

A role utilizada pelo pipeline possui permissoes restritas ao escopo necessario:

- **S3** - Leitura/escrita do estado Terraform
- **EC2** - Gerenciamento de VPC, subnets, security groups, NAT/Internet gateways
- **EKS** - Operacoes completas de cluster e node groups
- **IAM** - Gerenciamento de roles, policies e OIDC providers
- **KMS** - Operacoes de criptografia e gerenciamento de grants
- **ELB** - Provisionamento de load balancers (ALB/NLB)
- **CloudWatch** - Gerenciamento de log groups e streams
- **Auto Scaling** - Operacoes de scaling groups

---

## Variaveis Terraform

| Variavel | Tipo | Default | Descricao |
|:--|:--|:--|:--|
| `aws_region` | `string` | `us-east-1` | Regiao AWS |
| `project_name` | `string` | `eks-devops` | Nome do projeto |
| `vpc_cidr` | `string` | `10.0.0.0/16` | CIDR da VPC |
| `azs` | `list(string)` | `[us-east-1a, 1b, 1c]` | Zonas de disponibilidade |
| `private_subnets` | `list(string)` | `[10.0.1-3.0/24]` | CIDRs das subnets privadas |
| `public_subnets` | `list(string)` | `[10.0.101-103.0/24]` | CIDRs das subnets publicas |
| `cluster_name` | `string` | `eks-devops` | Nome do cluster EKS |
| `cluster_version` | `string` | `1.30` | Versao do Kubernetes |
| `kms_key_arn` | `string` | *(configurado)* | ARN da chave KMS |
| `node_groups` | `map(object)` | 3x t3.small | Configuracao dos node groups |
| `tags` | `map(string)` | Project, ManagedBy | Tags comuns |

---

## Outputs Terraform

| Output | Descricao |
|:--|:--|
| `vpc_id` | ID da VPC |
| `vpc_cidr_block` | CIDR block da VPC |
| `private_subnets` | IDs das subnets privadas |
| `public_subnets` | IDs das subnets publicas |
| `cluster_name` | Nome do cluster EKS |
| `cluster_endpoint` | Endpoint da API do Kubernetes |
| `cluster_arn` | ARN do cluster |
| `cluster_certificate_authority_data` | Certificado CA (base64) |
| `cluster_oidc_issuer_url` | URL do OIDC Provider |
| `oidc_provider_arn` | ARN do OIDC Provider (para IRSA) |

---

<div align="center">

**Desenvolvido com Terraform, Kubernetes e AWS**

</div>
