resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}

module "subnets" {
  for_each = var.subnets
  source   = "./subnets"
  name     = each.value["name"]
  subnets  = each.value["subnets_cidr"]
  vpc_id   = aws_vpc.main.id
  AZ       = var.AZ
  ngw      = try(each.value["ngw"], false)
  igw      = try(each.value["igw"], false)
  route_tables = aws_route_table.route-tables
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "$(var.env)-igw"
  }
}

#resource "aws_eip" "ngw" {
  #vpc = true
#}

#resource "aws_nat_gateway" "example" {
  #allocation_id = aws_eip.ngw.id
  #subnet_id     = module.subnets["public"].out[*].id[0]

  #tags = {
    #Name = "gw NAT"
  #}
#}
resource "aws_route_table" "route-tables" {
  for_each = var.subnets
  vpc_id   = aws_vpc.main.id

  tags     = {
    Name = "${each.value["name"]}-rt"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.route-tables["public"].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_tble_association" "public" {
  count          = length(module.subnets["public"].out[*].id)
  subnet_id      = element(module.subnets["public"].out[*].id, count.index)
  route_table_id = aws_route_table.route-tables["public"].id
}


output "out" {
  value = module.subnets["public"].out[*].id
}



#output "out" {
  #value = aws_route_table.route-tables
#}



