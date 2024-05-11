data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-b60"
    key    = "terraform-mutable/vpc/${var.env}/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_secretsmanager_secret" "secrets" {
  name = var.env
}

data "aws_secretsmanager_secret_version" "secrets-version" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}
