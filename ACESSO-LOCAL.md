# Como Acessar o Cluster EKS do Terminal Local

## Pré-requisitos

1. **AWS CLI instalado e configurado**
   ```bash
   aws --version
   # Se não tiver instalado:
   # Ubuntu/Debian: sudo apt-get install awscli
   # macOS: brew install awscli
   ```

2. **kubectl instalado**
   ```bash
   kubectl version --client
   # Se não tiver instalado:
   # Ubuntu/Debian: sudo apt-get install kubectl
   # macOS: brew install kubectl
   ```

3. **Credenciais AWS configuradas**
   ```bash
   aws configure
   # Ou configure via variáveis de ambiente
   ```

## Passo a Passo

### 1. Configurar credenciais AWS (se ainda não fez)

```bash
aws configure
# AWS Access Key ID: [sua access key]
# AWS Secret Access Key: [sua secret key]
# Default region name: us-east-1
# Default output format: json
```

Ou use um perfil específico:
```bash
aws configure --profile meu-perfil
```

### 2. Atualizar kubeconfig para conectar ao cluster

```bash
aws eks update-kubeconfig --region us-east-1 --name eks-devops
```

Se usar um perfil AWS específico:
```bash
aws eks update-kubeconfig --region us-east-1 --name eks-devops --profile meu-perfil
```

### 3. Verificar conexão

```bash
# Verificar se está conectado
kubectl cluster-info

# Listar nodes do cluster
kubectl get nodes

# Listar pods
kubectl get pods

# Listar services
kubectl get svc

# Listar deployments
kubectl get deployments
```

### 4. Verificar sua aplicação

```bash
# Ver pods da aplicação
kubectl get pods -l app=api

# Ver logs de um pod
kubectl logs -l app=api

# Ver detalhes do service
kubectl describe svc api-service

# Ver detalhes do deployment
kubectl describe deployment api-deployment
```

## Comandos Úteis

### Ver todos os recursos
```bash
kubectl get all
```

### Acessar um pod (shell interativo)
```bash
kubectl exec -it <nome-do-pod> -- /bin/bash
```

### Port-forward para acessar localmente
```bash
# Se o service for do tipo ClusterIP, use port-forward
kubectl port-forward svc/api-service 8080:80

# Depois acesse: http://localhost:8080
```

### Ver logs em tempo real
```bash
kubectl logs -f <nome-do-pod>
```

### Deletar recursos
```bash
kubectl delete deployment api-deployment
kubectl delete svc api-service
```

## Troubleshooting

### Erro: "Unable to connect to the server"
- Verifique se as credenciais AWS estão corretas: `aws sts get-caller-identity`
- Verifique se o cluster existe: `aws eks describe-cluster --name eks-devops --region us-east-1`
- Reconfigure o kubeconfig: `aws eks update-kubeconfig --region us-east-1 --name eks-devops`

### Erro: "Access Denied"
- Verifique se sua role/usuário tem permissões para acessar o EKS
- Verifique se o endpoint público está habilitado (já está configurado)

### Verificar contexto atual
```bash
kubectl config current-context
kubectl config get-contexts
```

### Mudar de contexto (se tiver múltiplos clusters)
```bash
kubectl config use-context <nome-do-contexto>
```

## Informações do Cluster

- **Nome**: eks-devops
- **Região**: us-east-1
- **Versão**: 1.30
- **Endpoint**: Público habilitado (acesso de qualquer lugar)
- **Nodes**: 3 nodes (t3.small)

