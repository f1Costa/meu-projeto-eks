#!/bin/bash

# Script para aplicar a política IAM atualizada na role GitHubActionsEKSRole

ROLE_NAME="GitHubActionsEKSRole"
POLICY_NAME="EKSTerraformPolicy"
POLICY_FILE="eks-terraform-policy.json"

echo "Aplicando política IAM atualizada na role: $ROLE_NAME"

# Verifica se o arquivo de política existe
if [ ! -f "$POLICY_FILE" ]; then
    echo "Erro: Arquivo $POLICY_FILE não encontrado!"
    exit 1
fi

# Aplica a política como inline policy
aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name "$POLICY_NAME" \
    --policy-document file://"$POLICY_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Política aplicada com sucesso!"
    echo ""
    echo "Verificando política aplicada:"
    aws iam get-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-name "$POLICY_NAME"
else
    echo "❌ Erro ao aplicar a política. Verifique:"
    echo "   1. Se você tem permissões para modificar a role"
    echo "   2. Se a role $ROLE_NAME existe"
    echo "   3. Se suas credenciais AWS estão configuradas"
    exit 1
fi

