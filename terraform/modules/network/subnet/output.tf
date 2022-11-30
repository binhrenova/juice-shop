output "name" {
  value = var.name
}

output "id" {
  value = aws_subnet.subnet.id
}

output "arn" {
  value = aws_subnet.subnet.arn
}

output "cidr_block" {
  value = var.cidr_block
}

output "route_table" {
  value = var.route_table
}