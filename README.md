# fiap-tech-challenge-terraform-db

Infraestrutura de banco de dados do **AutoFlow** — provisiona RDS PostgreSQL
via Terraform, integrando-se à VPC e Security Groups criados pelo repo k8s.

## Tecnologias

| Camada | Tecnologia                         |
| ------ | ---------------------------------- |
| Cloud  | AWS RDS PostgreSQL 16              |
| IaC    | Terraform 1.5+                     |
| CI/CD  | GitHub Actions                     |

## Posição no fluxo multi-repo

```
1. k8s  (Fase 1)  →  cria VPC, subnets privadas, SG do RDS   ← pré-requisito
2. db   (este)    →  lê outputs do k8s via S3, cria RDS
3. lambda         →  lê DB endpoint + credenciais do state deste repo
4. codebase       →  lê DB endpoint + credenciais do state deste repo
```

Este repo lê do state S3 do repo k8s:
- `private_subnet_ids` — para o DB Subnet Group
- `rds_security_group_id` — para o Security Group da instância

O state deste repo fica em:
`s3://fiap-tc-tfstate-{ACCOUNT_ID}/db-infra/terraform.tfstate`

Outros repos leem daqui sem precisar de secrets manuais:

| Output         | Lido por           |
| -------------- | ------------------ |
| `db_address`   | lambda, codebase   |
| `db_name`      | lambda, codebase   |
| `db_username`  | lambda, codebase   |
| `db_password`  | lambda, codebase   |
| `db_port`      | lambda, codebase   |

## Senha do banco

A senha é **gerada automaticamente** pelo Terraform (`random_password`) e
gravada encriptada no state S3. Nenhum secret manual é necessário no GitHub
e nenhuma senha precisa ser inventada ou rotacionada manualmente.

Para ver a senha após o apply:
```bash
terraform output -raw db_password
# ou
aws s3 cp s3://fiap-tc-tfstate-{ACCOUNT_ID}/db-infra/terraform.tfstate - | \
  jq -r '.outputs.db_password.value'
```

## Estrutura

```
main.tf          ← provider AWS + data source do state k8s
rds.tf           ← random_password + subnet group + parameter group + instância
outputs.tf       ← endpoint, credenciais (sensitive)
variables.tf     ← configurações sem dados sensíveis
versions.tf      ← versões dos providers (aws ~> 5.40, random ~> 3.6)

environments/
  dev.tfvars     ← db.t3.micro, 20 GB, single-AZ
  staging.tfvars ← db.t3.small, 20 GB, single-AZ
  prod.tfvars    ← db.r6g.large, 50 GB, multi-AZ, delete protection

scripts/
  bootstrap.sh      ← cria bucket S3 e gera backend.tf
  local-plan.sh     ← valida plano localmente
  local-apply.sh    ← cria o RDS localmente
  local-destroy.sh  ← destrói o RDS localmente (com confirmação)
```

## Secrets no GitHub

| Secret                  | Descrição                                         |
| ----------------------- | ------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | Credencial AWS Lab                                |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS Lab                                |
| `AWS_SESSION_TOKEN`     | Session token (obrigatório no Lab, expira em ~4h) |

Não há secret de senha — ela é gerada automaticamente.

## CI/CD

| Evento         | Comportamento                         |
| -------------- | ------------------------------------- |
| PR para `main` | `terraform fmt` + `validate` + `plan` |
| Merge em `main`| `terraform apply` automático          |

## Subir localmente

### 1. Pré-requisito

O repo **k8s deve estar deployado** antes (Fase 1 já aplicada).

### 2. Credenciais

```bash
cp .env.local.example .env.local
# edite com AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN
```

### 3. Aplicar

```bash
./scripts/local-apply.sh
# ou para outro ambiente:
./scripts/local-apply.sh environments/staging.tfvars
```

Isso executa automaticamente:
- `bootstrap.sh` (cria/valida bucket S3, gera `backend.tf`)
- `terraform init`
- `terraform apply` (cria RDS em ~5 min)
- Exibe o endpoint ao final

### 4. Validar sem aplicar

```bash
./scripts/local-plan.sh
```

### 5. Destruir

```bash
./scripts/local-destroy.sh
```

O script pede confirmação digitando `destroy`. Remove o RDS e o state file
`db-infra/terraform.tfstate` do bucket S3.

> Se `db_deletion_protection = true` (prod), o destroy vai falhar por design.
> Use o tfvars de dev ou ajuste a variável antes.

## Ambientes

| Arquivo               | Classe        | Storage | Multi-AZ | Delete Protection |
| --------------------- | ------------- | ------- | -------- | ----------------- |
| `environments/dev.tfvars`     | db.t3.micro   | 20 GB   | false    | false             |
| `environments/staging.tfvars` | db.t3.small   | 20 GB   | false    | false             |
| `environments/prod.tfvars`    | db.r6g.large  | 50 GB   | true     | true              |
