variable "vpc_id" {
  description = "The vpc we want it to lauch and set variables"
}

variable "name" {
  description = "Our naming convention for naming"
}

variable "my_ip" {
  description = "Our IP address"
}

variable "internet_gateway_id" {
  description = "Our igw id"
}

variable "db_private_ip" {
  description = "Our private ip of db instance"
}