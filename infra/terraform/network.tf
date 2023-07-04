resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"

  tags = {
    Name        = join("_", [var.project_name, "_vpc"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

# ----------------  PUBLIC NETWORK -----------------

resource "aws_subnet" "public" {
  for_each = toset(local.availability_zones)

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value
  cidr_block              = var.public_subnets[index(local.availability_zones, each.value)]
// CIDR can also be generated automatically without subnet variables
// cidr_block             = format("10.0.%s.0/24", index(local.availability_zones, each.value))
  map_public_ip_on_launch = true

  tags = {
    Name        = join("_", [var.project_name, "_public_subnet"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = join("_", [var.project_name, "_ig"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = join("_", [var.project_name, "_public_rt"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_route_table_association" "public" {
  for_each        = aws_subnet.public

  subnet_id       = each.value.id
  route_table_id  = aws_route_table.public.id
}

resource "aws_eip" "this" {
  for_each   = aws_subnet.public

  vpc        = true

  tags = {
    Name        = join("_", [var.project_name, "_nat_gw_eip"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }

  # Dependency is used to ensure that VPC has an Internet gateway
  depends_on = [ aws_internet_gateway.this ]
}

resource "aws_nat_gateway" "this" {
  for_each          = aws_subnet.public

  connectivity_type = "public"
  subnet_id         = aws_subnet.public[each.key].id
  allocation_id     = aws_eip.this[each.key].id

  tags = {
    Name        = join("_", [var.project_name, "_nat_gw"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }

  # Dependency is used to ensure that VPC has an Internet gateway
  depends_on = [aws_internet_gateway.this]
}

data "aws_route53_zone" "lerkasan_net" {
  name         = "lerkasan.net"
  private_zone = false
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.lerkasan_net.zone_id
  name    = data.aws_route53_zone.lerkasan_net.name
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}

# ----------------  PRIVATE NETWORK -----------------

resource "aws_subnet" "private" {
  for_each                = toset(local.availability_zones)

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value
  cidr_block              = var.private_subnets[index(local.availability_zones, each.value)]
  // CIDR can also be generated automatically without subnet variables
  // cidr_block             = format("10.0.%s.0/24", format("%d", 250 - index(local.availability_zones, each.value)))

  tags = {
    Name        = join("_", [var.project_name, "_private_subnet"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_route_table" "private" {
  for_each     = aws_nat_gateway.this

  vpc_id       = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = each.value.id
  }

  tags = {
    Name        = join("_", [var.project_name, "_private_rt"])
    terraform   = "true"
    environment = var.environment
    project     = var.project_name
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

