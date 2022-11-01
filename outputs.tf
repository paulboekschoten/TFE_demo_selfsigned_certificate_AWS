output "public_ip" {
  description = "Public IP of the TFE host."
  value       = aws_instance.paul-tfe.public_ip
}

output "private_ssh_key" {
  description = "Private SSH key."
  value = tls_private_key.rsa-4096.private_key_pem
  sensitive = true
}