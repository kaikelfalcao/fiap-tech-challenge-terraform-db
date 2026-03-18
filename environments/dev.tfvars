region       = "us-east-1"
environment  = "dev"
project_name = "fiap-tcdb"

# RDS
db_engine_version          = "16.3"
db_instance_class          = "db.t3.micro"
db_allocated_storage       = 20
db_max_allocated_storage   = 50
db_name                    = "app"
db_username                = "app"
db_multi_az                = false
db_backup_retention_period = 7
db_deletion_protection     = false
db_skip_final_snapshot     = true
