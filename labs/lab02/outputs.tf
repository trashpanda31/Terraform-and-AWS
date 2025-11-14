output "eip" {
  value       = aws_eip.web.public_ip
  description = "Elastic IP of the web server"
}

output "url" {
  value       = "http://${aws_eip.web.public_ip}"
  description = "Open this in your browser"
}

output "ssh_key_path" {
  value       = local_file.private_key_pem.filename
  description = "Path to the generated SSH private key"
}

output "ssh_command" {
  value       = "ssh -i ${local_file.private_key_pem.filename} ec2-user@${aws_eip.web.public_ip}"
  description = "SSH command to connect"
}

