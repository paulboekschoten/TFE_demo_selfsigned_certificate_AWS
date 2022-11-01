output "public_ip" {
  description = "Public IP of the TFE host."
  value       = aws_instance.paul-tfe.public_ip
}

output "private_ssh_key" {
  description = "Private SSH key."
  value       = tls_private_key.rsa-4096.private_key_pem
  sensitive   = true
}

output "replicated_dashboard" {
  description = "Url for Replicated dashboard."
  value       = "https://${ aws_instance.paul-tfe.public_ip }:8800"
}

output "tfe_login" {
  description = "Url for TFE login."
  value       = "https://${ aws_instance.paul-tfe.public_ip }"
}