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
  db_name              = "mysql-dev"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = local.ssh_pass
  password             = local.ssh_pass
  parameter_group_name = aws_db_parameter_group.mysql-pg.name
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.mysql.id]
  db_subnet_group_name   = aws_db_subnet_group.mysql-subnet-group.name
}

resource "aws_security_group" "mysql" {
  name        = "mysql-${var.env}"
  description = "mysql-${var.env}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress = [
    {
      description      = "MYSQL"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = local.ALL_CIDR
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "mysql-${var.env}"
  }
}

resource "aws_route53_record" "mysql" {
  zone_id = data.terraform_remote_state.vpc.outputs.INTERNAL_HOSTEDZONE_ID
  name    = "mysql-${var.env}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.mysql.address]
}

resource "null_resource" "schema-apply" {
  //depends_on = [aws_route53_record.mysql]
  provisioner "local-exec" {
    command = <<EOF
sudo yum install mariadb -y
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
cd /tmp
unzip -o /tmp/mysql.zip
mysql -h${aws_db_instance.mysql.address} -u${local.ssh_user} -p${local.ssh_pass} <mysql-main/shipping.sql
EOF
  }
}
