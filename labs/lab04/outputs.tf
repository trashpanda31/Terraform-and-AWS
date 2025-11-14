output "frontend_public_ip" {
  value       = aws_instance.frontend.public_ip
  description = "Frontend public ipv4"
}

output "backend_private_ip" {
  value       = aws_instance.backend.private_ip
  description = "backend private ipv4"
}

output "frontend_url" {
  value       = "http://${aws_eip.frontend.public_ip}"
  description = "Open it"
}

