#!/usr/bin/env bash
# Aplica a infra de banco localmente.
# PRÉ-REQUISITO: repo k8s deve estar deployado primeiro (VPC, SGs disponíveis).
# Uso: ./scripts/local-apply.sh [environments/dev.tfvars]
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

bash scripts/bootstrap.sh

terraform init -input=false -reconfigure

terraform apply -auto-approve -input=false \
  -var-file="$TFVARS"

echo ""
echo "=== Deploy concluído ==="
echo "Endpoint RDS:"
terraform output db_endpoint
echo ""
echo "Outros outputs (sensíveis — use: terraform output -json):"
echo "  db_address, db_port, db_name, db_username, db_password"
