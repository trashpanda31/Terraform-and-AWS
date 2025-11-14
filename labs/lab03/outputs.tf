output "eip" {
  value       = aws_eip.web.public_ip
  description = "Elastic IP of the web host"
}

output "url" {
  value       = "http://${aws_eip.web.public_ip}"
  description = "Open this in your browser"
}
