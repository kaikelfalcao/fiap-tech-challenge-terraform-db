region       = "us-east-1"
environment  = "prod"
project_name = "fiap-tcdb"

# RDS
db_engine_version          = "16.3"
db_instance_class          = "db.r6g.large"
db_allocated_storage       = 50
db_max_allocated_storage   = 200
db_name                    = "app"
db_username                = "app"
db_multi_az                = true
db_backup_retention_period = 14
db_deletion_protection     = true
db_skip_final_snapshot     = false
