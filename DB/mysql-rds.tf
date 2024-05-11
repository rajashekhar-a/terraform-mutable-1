resource "aws_db_subnet_group" "mysql-subnet-group" {
  name       = "mysql-dev-sg"
  subnet_ids = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS_IDS

  tags = {
    Name = "mysql-dev-sg"
  }
}

resource "aws_db_parameter_group" "mysql-pg" {
  name   = "mysql-dev-pg"
  family = "mysql5.7"
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 10
  db_name              = "mysql-{var.ENV}"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = aws_db_parameter_group.mysql-pg.name
  skip_final_snapshot  = true
}