#!/usr/bin/env bash
# Destrói o banco de dados e limpa o state do S3.
# AVISO: se db_deletion_protection=true no tfvars, o destroy vai falhar —
#        desabilite antes ou use o tfvars de dev (padrão).
# Uso: ./scripts/local-destroy.sh [environments/dev.tfvars]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

ENV_FILE="${ROOT_DIR}/.env.local"
if [ ! -f "$ENV_FILE" ]; then
  echo "ERRO: .env.local não encontrado."
  echo "      Copie .env.local.example → .env.local e preencha as credenciais."
  exit 1
fi
# shellcheck source=/dev/null
source "$ENV_FILE"

TFVARS="${1:-environments/dev.tfvars}"

# Garante que backend.tf existe antes de init
if [ ! -f backend.tf ]; then
  bash scripts/bootstrap.sh
fi

terraform init -input=false -reconfigure

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║  ATENÇÃO: isso vai destruir o banco de dados  ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""
read -r -p "Confirme digitando 'destroy': " CONFIRM
if [ "$CONFIRM" != "destroy" ]; then
  echo "Cancelado."
  exit 1
fi

terraform destroy -auto-approve -input=false \
  -var-file="$TFVARS"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET="fiap-tc-tfstate-${ACCOUNT_ID}"

echo ""
echo "=== Removendo state file db-infra do S3 ==="
aws s3 rm "s3://${BUCKET}/db-infra/terraform.tfstate" 2>/dev/null || true
aws s3 rm "s3://${BUCKET}/db-infra/terraform.tfstate.tflock" 2>/dev/null || true

echo ""
echo "=== Banco destruído sem rastros. ==="
