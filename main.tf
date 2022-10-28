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
  key_name   = "${ var.environment }-keypair"
  public_key = tls_private_key.rsa-4096.public_key_openssh
}