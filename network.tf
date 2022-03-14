#
# VPC

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

#
# Internet Gateway
#
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

#
# Subnets
#
resource "aws_subnet" "private-eu-1a" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "eu-central-1a"

  tags = {
    "name"                              = "private-eu-1a"
    "kubernetes.io/role/internal-elb"   = "1"
    "kubernetes.io/cluster/eks-cluster" = "owned"
  }
}

resource "aws_subnet" "private-eu-1b" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "eu-central-1b"

  tags = {
    "name"                              = "private-eu-1b"
    "kubernetes.io/role/internal-elb"   = "1"
    "kubernetes.io/cluster/eks-cluster" = "owned"
  }
}

resource "aws_subnet" "public-eu-1a" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "eu-central-1a"

  tags = {
    "name"                              = "public-eu-1a"
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/eks-cluster" = "owned"
  }
}

resource "aws_subnet" "public-eu-1b" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "eu-central-1b"

  tags = {
    "name"                       = "public-eu-1b"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/eks-cluster" = "owned"
  }
}

#
# NAT Gateway
#
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "eu-1a" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-eu-1a.id

  depends_on = [aws_internet_gateway.default]
}

# 
# Route Tables
#
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id

  route {

      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.eu-1a.id
    }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.default.id
    }
}

#
# Route Table Association
#
resource "aws_route_table_association" "private-eu-1a" {
  subnet_id      = aws_subnet.private-eu-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-eu-1b" {
  subnet_id      = aws_subnet.private-eu-1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-eu-1a" {
  subnet_id      = aws_subnet.public-eu-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-eu-1b" {
  subnet_id      = aws_subnet.public-eu-1b.id
  route_table_id = aws_route_table.public.id
}
