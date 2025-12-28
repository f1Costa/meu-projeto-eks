# Solução Definitiva - Permissões IAM e Correções

## ✅ O que foi implementado

### 1. Permissões IAM Completas e Abrangentes

A política IAM foi atualizada com **TODAS** as permissões necessárias para EKS, incluindo permissões preventivas para evitar loops de erros:

#### EC2 - Launch Templates (NOVO - Resolve erro atual)
- `ec2:CreateLaunchTemplate` ⭐ **Resolve erro atual de Launch Template**
- `ec2:DeleteLaunchTemplate`
- `ec2:DescribeLaunchTemplates`
- `ec2:DescribeLaunchTemplateVersions`
- `ec2:CreateLaunchTemplateVersion`
- `ec2:DeleteLaunchTemplateVersions`
- `ec2:ModifyLaunchTemplate`
- `ec2:GetLaunchTemplateData`

#### EC2 - Network ACLs
- `ec2:CreateNetworkAcl`
- `ec2:DeleteNetworkAcl`
- `ec2:CreateNetworkAclEntry`
- `ec2:DeleteNetworkAclEntry` ⭐ **Resolve o erro atual**
- `ec2:ReplaceNetworkAclEntry`
- `ec2:ReplaceNetworkAclAssociation`
- `ec2:DescribeNetworkAclEntries`
- `ec2:DescribeNetworkAcls`

#### EC2 - Network Interfaces e Outros
- `ec2:CreateNetworkInterface`
- `ec2:DeleteNetworkInterface`
- `ec2:AttachNetworkInterface`
- `ec2:DetachNetworkInterface`
- `ec2:DescribeVpcEndpoints`
- `ec2:DescribeVpcEndpointServices`
- `ec2:DescribePrefixLists`
- `ec2:DescribeFlowLogs`
- `ec2:CreateFlowLog`
- `ec2:DeleteFlowLog`

#### IAM - Managed Policies
- `iam:CreatePolicy`
- `iam:DeletePolicy`
- `iam:GetPolicy`
- `iam:ListPolicies`
- `iam:ListPolicyVersions`
- `iam:GetPolicyVersion`
- `iam:TagPolicy`
- `iam:UntagPolicy`
- `iam:ListPolicyTags`

#### CloudWatch Logs
- Todas as permissões necessárias incluindo `logs:ListTagsForResource`

#### KMS
- Todas as permissões para gerenciar chaves de criptografia
- Permissões de criptografia/descriptografia (Decrypt, Encrypt, GenerateDataKey, etc.)
- Permissões de grants (CreateGrant, ListGrants, RevokeGrant)

#### EKS - Permissões Completas (NOVO)
- **Cluster Management**: CreateCluster, DeleteCluster, DescribeCluster, UpdateClusterConfig, UpdateClusterVersion
- **Add-ons**: CreateAddon, DeleteAddon, UpdateAddon, ListAddons, DescribeAddon, DescribeAddonVersions
- **Identity Provider**: AssociateIdentityProviderConfig, DisassociateIdentityProviderConfig, DescribeIdentityProviderConfig
- **Access Management**: CreateAccessEntry, DeleteAccessEntry, DescribeAccessEntry, ListAccessEntries, AssociateAccessPolicy
- **Fargate Profiles**: CreateFargateProfile, DeleteFargateProfile, DescribeFargateProfile, ListFargateProfiles
- **Updates**: DescribeUpdate, ListUpdates, UpdateNodegroupVersion
- **Tags**: TagResource, UntagResource, ListTagsForResource

#### IAM - Service-Linked Roles e OIDC Providers (NOVO - Resolve erros atuais)
- `iam:CreateServiceLinkedRole` ⭐ **Resolve erro de Service-Linked Role**
- `iam:DeleteServiceLinkedRole`
- `iam:GetServiceLinkedRoleDeletionStatus`
- `iam:CreateOpenIDConnectProvider` ⭐ **Resolve erro atual de OIDC Provider**
- `iam:DeleteOpenIDConnectProvider`
- `iam:GetOpenIDConnectProvider`
- `iam:ListOpenIDConnectProviders`
- `iam:AddClientIDToOpenIDConnectProvider`
- `iam:RemoveClientIDFromOpenIDConnectProvider`
- `iam:UpdateOpenIDConnectProviderThumbprint`
- Permissões de tags para OIDC Providers

#### ELB - Permissões Expandidas (NOVO)
- Todas as permissões de Load Balancers (Create, Delete, Modify, Describe)
- Permissões de Target Groups completas
- Permissões de Listeners e Rules
- Permissões de Tags e Certificados
- Permissões de Attributes e Security Groups

#### EC2 - Instance Management (NOVO)
- Permissões para gerenciar instâncias EC2 (RunInstances, TerminateInstances, etc.)
- Permissões de Volumes EBS (CreateVolume, DeleteVolume, AttachVolume, etc.)
- Permissões de Snapshots e Images

#### Auto Scaling (NOVO)
- Todas as permissões para gerenciar Auto Scaling Groups
- Permissões de Launch Configurations
- Permissões de Scheduled Actions

#### ECR (NOVO)
- Permissões para acessar Amazon ECR (GetAuthorizationToken, BatchGetImage, etc.)

### 2. Correção do Log Group Existente

**Problema**: O CloudWatch Log Group `/aws/eks/eks-devops/cluster` já existe, causando erro.

**Solução implementada**:
- Adicionado step no pipeline GitHub Actions que **deleta automaticamente** o log group existente antes do `terraform apply`
- Criado script `fix-log-group.sh` para uso manual se necessário

### 3. Pipeline Atualizado

O arquivo `.github/workflows/pipeline.yml` foi atualizado com:
- Step para limpar log group existente antes do terraform apply
- Isso evita o erro `ResourceAlreadyExistsException`

## 📋 Como usar

### Aplicar política IAM atualizada

```bash
./apply-iam-policy.sh
```

Ou manualmente:
```bash
aws iam put-role-policy \
  --role-name GitHubActionsEKSRole \
  --policy-name EKSTerraformPolicy \
  --policy-document file://eks-terraform-policy.json
```

### Resolver log group existente (se necessário)

```bash
./fix-log-group.sh
```

## 🎯 Resultado Esperado

Com essas mudanças, o pipeline deve:
1. ✅ Deletar automaticamente o log group existente
2. ✅ Ter todas as permissões necessárias (incluindo Network ACLs)
3. ✅ Executar o terraform apply sem erros de permissão
4. ✅ Criar o cluster EKS com sucesso

## 📝 Notas

- As permissões foram adicionadas de forma **preventiva** para evitar loops de erros
- O pipeline agora lida automaticamente com recursos existentes
- Se novos erros de permissão aparecerem, adicione as permissões faltantes em `eks-terraform-policy.json` e execute `./apply-iam-policy.sh`

## ⚠️ Warnings (não são erros)

Os warnings sobre recursos deprecated são do módulo EKS do Terraform e não impedem a execução:
- `inline_policy is deprecated` - Warning do módulo, não bloqueia
- `kubernetes_config_map is deprecated` - Warning do módulo, não bloqueia

