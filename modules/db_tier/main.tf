// DB SETUP -- Private Subnet !

# Create private sub
resource "aws_subnet" "subprivate" {
  vpc_id     = var.vpc_id
  cidr_block = "23.0.2.0/24"
  availability_zone = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}sub.private"
  }
}

# Creating security group for db
resource "aws_security_group" "sgdb" {
  name        = "db-sg"
  description = "Allow http and https traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "https from VPC"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
//    cidr_blocks = ["23.0.1.0/24"]
    security_groups = [var.sg-app]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}sg.db"
  }
}

# Create private NACL
resource "aws_network_acl" "naclprivate" {
  vpc_id = var.vpc_id

  # traffic on por 80 allow
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    rule_no     = 100
    action      = "allow"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_block = var.subpublic_cidr_block
  }

  subnet_ids = [aws_subnet.subprivate.id]

  tags = {
    Name = "${var.name}nacls.private"
  }
}

# Creating an ec2 instance IMAGE with our db
resource "aws_instance" "DB" {
  ami           = "ami-097a1923bb6d9c21d"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subprivate.id
  vpc_security_group_ids = [aws_security_group.sgdb.id]
  tags = {
    Name = "${var.name}tf.db"
  }
}