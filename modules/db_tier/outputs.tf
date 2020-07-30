output "db_private_ip" {
  description = "private ip for db instance"
  value = aws_instance.DB.private_ip
}

