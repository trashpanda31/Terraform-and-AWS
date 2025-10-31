output "vpc_id" {
  value = aws_vpc.vpc_lab01.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet_lab01.id
}

output "instance_id" {
  value = aws_instance.vm.id
}

output "instance_public_ip" {
  value = aws_instance.vm.public_ip
}

output "instance_public_dns" {
  value = aws_instance.vm.public_dns
}
