output "public_ip" {
  description = "Public IP of the TFE host."
  value       = aws_instance.paul-tfe.public_ip
}

output "replicated_dashboard" {
  description = "Url for Replicated dashboard."
  value       = "https://${ aws_instance.paul-tfe.public_ip }:8800"
}

output "tfe_login" {
  description = "Url for TFE login."
  value       = "https://${ aws_instance.paul-tfe.public_ip }"
}

output "ssh_login" {
  description = "SSH login command."
  value = "ssh -i tfesshkey.pem ubuntu@${ aws_instance.paul-tfe.public_ip }"
}