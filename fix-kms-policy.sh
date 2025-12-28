#!/bin/bash

# Script para adicionar permissão do usuário cloudOps à chave KMS do EKS

KEY_ID="74c0d196-1929-49a9-a8d8-ed6a088e27d4"
USER_ARN="arn:aws:iam::925445554210:user/cloudOps"

echo "🔐 Adicionando permissão KMS para o usuário cloudOps..."

# Obter a política atual da chave
aws kms get-key-policy --key-id "$KEY_ID" --policy-name default --output text > /tmp/kms-policy.json

# Adicionar statement para o usuário (se ainda não existir)
if ! grep -q "$USER_ARN" /tmp/kms-policy.json; then
    echo "Adicionando permissão na chave KMS..."
    
    # Criar política atualizada
    cat > /tmp/kms-policy-updated.json <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::925445554210:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow cloudOps user",
      "Effect": "Allow",
      "Principal": {
        "AWS": "$USER_ARN"
      },
      "Action": [
        "kms:DescribeKey",
        "kms:GetKeyPolicy",
        "kms:ListKeyPolicies",
        "kms:ListGrants",
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
    
    # Aplicar a política
    aws kms put-key-policy \
        --key-id "$KEY_ID" \
        --policy-name default \
        --policy file:///tmp/kms-policy-updated.json
    
    if [ $? -eq 0 ]; then
        echo "✅ Permissão adicionada com sucesso!"
    else
        echo "❌ Erro ao adicionar permissão"
        exit 1
    fi
else
    echo "✅ Permissão já existe"
fi

