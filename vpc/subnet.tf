resource "aws_subnet" "main" {
  count      = length(var.SUBNETS, count.index)
  vpc_id     = aws_vpc.main.id
  cidr_block = elements(var.SUBNETS, count.index)

  tags = {
    Name = "subnet-${count.index}"
  }
}