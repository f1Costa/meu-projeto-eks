#!/bin/bash

# Script para conectar ao cluster EKS localmente

CLUSTER_NAME="eks-devops"
REGION="us-east-1"

echo "🔗 Conectando ao cluster EKS: $CLUSTER_NAME"
echo ""

# Verificar se AWS CLI está instalado
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI não está instalado. Instale primeiro:"
    echo "   Ubuntu/Debian: sudo apt-get install awscli"
    echo "   macOS: brew install awscli"
    exit 1
fi

# Verificar se kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl não está instalado. Instale primeiro:"
    echo "   Ubuntu/Debian: sudo apt-get install kubectl"
    echo "   macOS: brew install kubectl"
    exit 1
fi

# Verificar credenciais AWS
echo "🔐 Verificando credenciais AWS..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Credenciais AWS não configuradas. Execute:"
    echo "   aws configure"
    exit 1
fi

echo "✅ Credenciais AWS OK"
echo ""

# Atualizar kubeconfig
echo "📝 Atualizando kubeconfig..."
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

if [ $? -eq 0 ]; then
    echo "✅ Kubeconfig atualizado com sucesso!"
    echo ""
    echo "🔍 Verificando conexão..."
    echo ""
    
    # Verificar cluster
    kubectl cluster-info
    echo ""
    
    # Listar nodes
    echo "📊 Nodes do cluster:"
    kubectl get nodes
    echo ""
    
    # Listar pods
    echo "📦 Pods em execução:"
    kubectl get pods
    echo ""
    
    # Listar services
    echo "🌐 Services:"
    kubectl get svc
    echo ""
    
    echo "✅ Conectado com sucesso ao cluster EKS!"
    echo ""
    echo "💡 Comandos úteis:"
    echo "   kubectl get pods"
    echo "   kubectl get svc"
    echo "   kubectl get deployments"
    echo "   kubectl logs -l app=api"
    echo "   kubectl port-forward svc/api-service 8080:80"
else
    echo "❌ Erro ao atualizar kubeconfig"
    exit 1
fi

