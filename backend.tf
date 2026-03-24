terraform {
  backend "s3" {
    bucket       = "fiap-tc-tfstate-891377234230"
    key          = "db-infra/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
