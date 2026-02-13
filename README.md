# FIAP Tech Challenge - Database Infrastructure

Terraform para provisionamento do banco de dados PostgreSQL (RDS) na AWS.

## Recursos Provisionados

- **RDS PostgreSQL 16** com storage encriptado (gp3)
- **DB Subnet Group** usando subnets privadas da VPC do EKS
- **Parameter Group** customizado com logging e pg_stat_statements
- **Backups automaticos** com retencao configuravel
- **Multi-AZ** (habilitado em producao)
- **Performance Insights** (habilitado em producao)

## Pre-requisitos

- Terraform >= 1.5.0
- AWS CLI configurado com credenciais
- S3 bucket e DynamoDB table para remote state
- **Repositorio `fiap-tech-challenge-k8s-infra` aplicado** (necessario para VPC, subnets e security groups)

## Dependencia

Este repositorio depende dos outputs do `fiap-tech-challenge-k8s-infra` via `terraform_remote_state`. Certifique-se de que o repositorio de infra K8s foi aplicado antes de aplicar este.

Dados consumidos do remote state:
- `private_subnet_ids` - subnets para o DB subnet group
- `rds_security_group_id` - security group que permite acesso dos nodes EKS

## Uso

```bash
# Inicializar
terraform init

# Planejar (dev)
terraform plan -var-file=environments/dev.tfvars -var="db_password=SUA_SENHA_SEGURA"

# Aplicar (dev)
terraform apply -var-file=environments/dev.tfvars -var="db_password=SUA_SENHA_SEGURA"
```

> **Nota:** A senha do banco de dados deve ser passada via variavel `-var` ou variavel de ambiente `TF_VAR_db_password`. Nunca armazene senhas em arquivos tfvars.

## Ambientes

| Arquivo | Descricao |
|---------|-----------|
| `environments/dev.tfvars` | Desenvolvimento - db.t3.micro, single-AZ, 20GB |
| `environments/staging.tfvars` | Staging - db.t3.small, single-AZ, 20GB |
| `environments/prod.tfvars` | Producao - db.r6g.large, multi-AZ, 50GB, delete protection |

## Outputs

| Output | Descricao |
|--------|-----------|
| `db_endpoint` | Endpoint completo (host:port) |
| `db_address` | Hostname do RDS |
| `db_port` | Porta do banco (5432) |
| `db_name` | Nome do banco de dados |
| `db_username` | Usuario master |
| `db_connection_info` | Mapa com variaveis de ambiente para a aplicacao |

## Configurando a Aplicacao

Apos aplicar o Terraform, use os outputs para configurar as variaveis de ambiente da aplicacao:

```bash
# Obter informacoes de conexao
terraform output -json db_connection_info

# Variaveis necessarias pela aplicacao:
# DATABASE_HOST = db_address
# DATABASE_PORT = 5432
# DATABASE_NAME = app
# DATABASE_USER = app
# DATABASE_PASSWORD = (senha definida no apply)
```
