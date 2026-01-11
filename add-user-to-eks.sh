#!/bin/bash

# Script para adicionar usuário IAM ao aws-auth ConfigMap do EKS

CLUSTER_NAME="eks-devops"
REGION="us-east-1"
USER_ARN=$USER_ARN

echo "🔐 Adicionando usuário ao aws-auth ConfigMap..."
echo "Usuário: $USER_ARN"
echo ""

# Verificar se kubectl está configurado (precisa ter acesso via outra forma primeiro)
# Ou usar aws eks update-kubeconfig com uma role que já tem acesso

# Baixar o ConfigMap atual
kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth-backup.yaml

# Adicionar o usuário ao ConfigMap
kubectl create configmap aws-auth \
  --from-file=mapUsers=/dev/stdin \
  -n kube-system \
  --dry-run=client -o yaml <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapUsers: |
    - userarn: $USER_ARN
      username: cloudOps
      groups:
        - system:masters
EOF

if [ $? -eq 0 ]; then
    echo "✅ Usuário adicionado com sucesso!"
    echo ""
    echo "Aguarde alguns segundos e tente novamente:"
    echo "  kubectl cluster-info"
    echo "  kubectl get nodes"
else
    echo "❌ Erro ao adicionar usuário"
    echo ""
    echo "Tentando método alternativo..."
    
    # Método alternativo: usar patch
    kubectl patch configmap aws-auth -n kube-system --type merge -p "{\"data\":{\"mapUsers\":\"- userarn: $USER_ARN\n  username: cloudOps\n  groups:\n    - system:masters\"}}"
fi

