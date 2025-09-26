vpc.tf
resource "aws_vpc" "vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${local.name}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# Public subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.pub_a
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = { Name = "${local.name}-public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.pub_b
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = { Name = "${local.name}-public-b" }
}

# Private subnets
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.priv_a
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = { Name = "${local.name}-private-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.priv_b
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = { Name = "${local.name}-private-b" }
}

# Public RT + default route
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "pub_a" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_a.id
}
resource "aws_route_table_association" "pub_b" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_b.id
}

# NAT for private subnets egress
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
  depends_on    = [aws_internet_gateway.igw]
}

# Private route tables
resource "aws_route_table" "private_a" { vpc_id = aws_vpc.vpc.id }
resource "aws_route_table" "private_b" { vpc_id = aws_vpc.vpc.id }

resource "aws_route" "priv_a_default" {
  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
resource "aws_route" "priv_b_default" {
  route_table_id         = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
resource "aws_route_table_association" "priv_a" {
  route_table_id = aws_route_table.private_a.id
  subnet_id      = aws_subnet.private_a.id
}
resource "aws_route_table_association" "priv_b" {
  route_table_id = aws_route_table.private_b.id
  subnet_id      = aws_subnet.private_b.id
}
