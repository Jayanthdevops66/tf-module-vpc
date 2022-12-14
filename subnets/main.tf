resource "aws_subnets" "main" {
  count = length(var.subnets)
  vpc_id     = var.vpc_id
  cidr_block = var.subnets[count.index]
  availability_zone_id = var.AZ[count.index]

  tags = {
    Name = "$(var.name)-subnet"
  }
}

output "out" {
  value = aws_subnets.main
}