#terraform settings
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.37.0"
    }
  }

  required_version = "1.3.3"
}

# provider settings
provider "aws" {
  region = var.region
}

# resources
# key pair
# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# key pair
resource "aws_key_pair" "paul-tf" {
  key_name   = "${var.environment}-keypair"
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

# security group
resource "aws_security_group" "paul-sg-tf" {
  name = "${var.environment}-sg"
}

# sg rule ssh inbound
resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.paul-sg-tf.id

  from_port   = var.ssh_port
  to_port     = var.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# sg rule https inbound
resource "aws_security_group_rule" "allow_https_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.paul-sg-tf.id

  from_port   = var.https_port
  to_port     = var.https_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# sg rule https inbound
resource "aws_security_group_rule" "allow_replicated_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.paul-sg-tf.id

  from_port   = var.replicated_port
  to_port     = var.replicated_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# sg rule all outbound
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.paul-sg-tf.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

# fetch ubuntu ami id for version 22.04
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# EC2 instance
resource "aws_instance" "paul-tfe" {
  ami                    = data.aws_ami.ubuntu.image_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.paul-tf.key_name
  vpc_security_group_ids = [aws_security_group.paul-sg-tf.id]

  user_data = templatefile("${path.module}/scripts/user_data.sh", {
    enc_password        = var.tfe_encryption_password,
    replicated_password = var.replicated_password,
    admin_username      = var.admin_username,
    admin_email         = var.admin_email,
    admin_password      = var.admin_password
  })

  root_block_device {
    volume_size = 100
  }

  tags = {
    Name = "${var.environment}-tfe"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.rsa-4096.private_key_pem
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "config/license.rli"
    destination = "/tmp/license.rli"
  }
}