# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "main-vpc"
  }
}

# Create Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

# Create public subnets on every AZ
resource "aws_subnet" "public_snet" {
    count                   = var.az_count

    cidr_block              = cidrsubnet(var.vpc_cidr, 4, var.az_count + count.index)
    availability_zone       = data.aws_availability_zones.available.names[count.index]
    vpc_id                  = aws_vpc.main.id
    map_public_ip_on_launch = true

    tags = {
      Name = "public-snet-${count.index}"
    }
}

# Route traffic through the Gateway
resource "aws_route" "internet_access" {
    route_table_id         = aws_vpc.main.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.main.id
}


