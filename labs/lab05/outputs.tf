output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnet_id" { value = module.vpc.public_subnet_id }
output "private_subnet_id" { value = module.vpc.private_subnet_id }

output "frontend_instance_id" { value = module.frontend.instance_id }
output "backend_instance_id" { value = module.backend.instance_id }

output "frontend_public_ip" { value = module.frontend.public_ip }
output "backend_private_ip" { value = module.backend.private_ip }

output "frontend_url_ip" {
  value = "http://${module.frontend.public_ip}"
}
