locals {
  public_subnets = {
    1 = {
      Name = "${var.env_name}-PUBLIC-1A"
      Cidr = "10.14.0.0/24"
      Zone = data.aws_availability_zones.available.names[0]
    }
    2 = {
      Name = "${var.env_name}-PUBLIC-1B"
      Cidr = "10.14.10.0/24"
      Zone = data.aws_availability_zones.available.names[1]
    }
  }

  private_subnets = {
    1 = {
      Name = "${var.env_name}-PRIVATE-1A"
      Cidr = "10.14.1.0/24"
      Zone = data.aws_availability_zones.available.names[0]
    }
    2 = {
      Name = "${var.env_name}-PRIVATE-1B"
      Cidr = "10.14.11.0/24"
      Zone = data.aws_availability_zones.available.names[1]
    }
  }

  local_route = []
}

##########################################
# VPC
##########################################

module "prod_vpc" {
  source = "../modules/network/vpc"

  name                 = "${var.env_name}-VPC"
  cidr_block           = "10.14.0.0/16"
  enable_dns_hostnames = true

  igw_name = "${var.env_name}-IGW"

  tags = merge(local.tags, {})
}

##########################################
# NAT Gateway
##########################################

# Elastic-IP (eip) for NAT Gateway
resource "aws_eip" "prod_nat_eip" {
  count = 1

  vpc = true
  depends_on = [
    module.prod_vpc
  ]
}

# NAT Gateway
resource "aws_nat_gateway" "prod_nat_gateway" {
  allocation_id = aws_eip.prod_nat_eip[0].id
  subnet_id     = module.prod_subnet_public[1].id

  tags = merge(local.tags, {
    Name = "${var.env_name}-NGW"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [
    module.prod_vpc,
    module.prod_subnet_public,
    aws_eip.prod_nat_eip
  ]
}

##########################################
# Subnets
##########################################
module "prod_subnet_public" {
  source = "../modules/network/subnet"

  for_each = local.public_subnets

  name              = each.value.Name
  availability_zone = each.value.Zone
  cidr_block        = each.value.Cidr
  vpc_id            = module.prod_vpc.id

  route_table             = aws_route_table.public.id
  map_public_ip_on_launch = true

  tags = merge(local.tags, {})

  depends_on = [
    module.prod_vpc
  ]
}

module "prod_subnet_private" {
  source = "../modules/network/subnet"

  for_each = local.private_subnets

  name              = each.value.Name
  availability_zone = each.value.Zone
  cidr_block        = each.value.Cidr
  vpc_id            = module.prod_vpc.id

  route_table = aws_route_table.private.id

  tags = {}

  depends_on = [
    module.prod_vpc
  ]
}

##########################################
# Route Tables
##########################################

resource "aws_route_table" "public" {
  vpc_id = module.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.prod_vpc.igw_id
  }

  dynamic "route" {
    for_each = local.local_route

    content {
      cidr_block         = route.value
      transit_gateway_id = var.dc_tgw_id
    }
  }

  tags = merge(local.tags, {
    Name = "${var.env_name}-PUBLIC-RTB"
  })
}

resource "aws_route_table" "private" {
  vpc_id = module.prod_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.prod_nat_gateway.id
  }

  dynamic "route" {
    for_each = local.local_route

    content {
      cidr_block         = route.value
      transit_gateway_id = var.dc_tgw_id
    }
  }

  tags = merge(local.tags, {
    Name = "${var.env_name}-PRIVATE-RTB"
  })
}
