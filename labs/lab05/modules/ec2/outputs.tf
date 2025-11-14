output "instance_id" { value = aws_instance.this.id }
output "private_ip" { value = aws_instance.this.private_ip }
output "public_ip" { value = try(aws_eip.this[0].public_ip, null) }
