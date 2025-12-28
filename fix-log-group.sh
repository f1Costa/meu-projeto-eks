#!/bin/bash

# Script para resolver o problema do CloudWatch Log Group existente
# Este script pode importar o log group existente ou deletá-lo

LOG_GROUP_NAME="/aws/eks/eks-devops/cluster"
REGION="us-east-1"

echo "Verificando se o log group existe: $LOG_GROUP_NAME"

# Verifica se o log group existe
if aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP_NAME" --region "$REGION" --query "logGroups[?logGroupName=='$LOG_GROUP_NAME']" --output text | grep -q "$LOG_GROUP_NAME"; then
    echo "⚠️  Log group encontrado: $LOG_GROUP_NAME"
    echo ""
    echo "Escolha uma opção:"
    echo "1. Deletar o log group existente (recomendado para fresh start)"
    echo "2. Importar o log group no Terraform"
    echo "3. Sair sem fazer nada"
    read -p "Digite sua escolha (1-3): " choice
    
    case $choice in
        1)
            echo "Deletando log group: $LOG_GROUP_NAME"
            aws logs delete-log-group --log-group-name "$LOG_GROUP_NAME" --region "$REGION"
            if [ $? -eq 0 ]; then
                echo "✅ Log group deletado com sucesso!"
            else
                echo "❌ Erro ao deletar log group"
                exit 1
            fi
            ;;
        2)
            echo "Para importar o log group, execute no diretório terraform:"
            echo "terraform import module.eks.aws_cloudwatch_log_group.this[0] $LOG_GROUP_NAME"
            ;;
        3)
            echo "Nenhuma ação realizada."
            exit 0
            ;;
        *)
            echo "Opção inválida"
            exit 1
            ;;
    esac
else
    echo "✅ Log group não existe. Nenhuma ação necessária."
fi

