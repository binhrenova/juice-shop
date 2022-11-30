output "id" {
  value = aws_vpc.vpc.id
}

output "arn" {
  value = aws_vpc.vpc.arn
}

output "instance_tenancy" {
  value = aws_vpc.vpc.instance_tenancy
}

output "enable_dns_support" {
  value = aws_vpc.vpc.enable_dns_support
}

output "enable_dns_hostnames" {
  value = aws_vpc.vpc.enable_dns_hostnames
}

output "cidr_block" {
  value = var.cidr_block
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

