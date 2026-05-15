# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "depi"
  }
}

# IGW
resource "aws_internet_gateway" "main-gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "depi"
  }
}

# Regional NAT GW
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat-gw" {
  subnet_id = aws_subnet.public_subnet["public_subnet_1"].id
  allocation_id = aws_eip.nat_eip.id
  tags = {
    Name = "depi NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main-gw]
}


# public rt
resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gw.id
  }

  tags = {
    Name = "depi public rtb"
  }
}

# private rt
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "depi private rtb"
  }
}

# Subnets (2 public, 2 private)
resource "aws_subnet" "public_subnet" {
  for_each          = var.public_subnet
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["az"]
  tags = {
    Name = "depi public subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  for_each          = var.private_subnet
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["az"]
  tags = {
    Name = "depi private subnet"
  }
}

# public subnet association
resource "aws_route_table_association" "public-association" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.pub-rt.id
}

# private subnet association
resource "aws_route_table_association" "private-association" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private-rt.id
}
