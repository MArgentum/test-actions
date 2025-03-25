provider "aws" {
  region = "eu-north-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "PostgreSQL from anywhere"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "ssh_key_tf_managed"
  public_key = var.ssh_public_key
}

variable "ssh_public_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHWGgCeR/N5uh/t5zLtPdNUbyhS6uXMZf4V0JcA/CGZt matvey-key"
}

resource "aws_instance" "example" {
  ami                    = "ami-04542995864e26699"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = aws_key_pair.deployer.key_name

  tags = {
    Name = "postgres"
  }
}
output "public_ip" {
  value = aws_instance.example.public_ip
}
