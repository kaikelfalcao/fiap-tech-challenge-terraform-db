#!/usr/bin/env bash
# Valida o plano Terraform localmente sem aplicar nada.
# Requer que o repo k8s já tenha sido deployado (lê outputs via remote state).
# Uso: ./scripts/local-plan.sh [environments/dev.tfvars]
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

terraform plan -lock=false -input=false \
  -var-file="$TFVARS"
