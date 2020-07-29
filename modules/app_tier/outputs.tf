output "security_group_id" {
  description = "id of security group for app"
  value = aws_security_group.sgapp.id
}

output "subpublic_cidr_block" {
  description = "cidr block of our public subnet"
  value = aws_subnet.subpublic.cidr_block
}