output "public_ip" {
  description = "Public IP of the TFE host."
  value       = aws_instance.paul-tfe.public_ip
}