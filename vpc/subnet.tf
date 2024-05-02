resource "aws_subnet" "main" {
  count      = length(var.SUBNET, count.index)
  vpc_id     = aws_vpc.main.id
  cidr_block = elements(var.SUBNET, count.index)

  tags = {
    Name = "subnet-${count.index}"
  }
}