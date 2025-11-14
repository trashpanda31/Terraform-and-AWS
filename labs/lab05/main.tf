module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "security" {
  source        = "./modules/security"
  vpc_id        = module.vpc.vpc_id
  frontend_port = var.frontend_port
  backend_port  = var.backend_port
}

module "iam_ssm" {
  source      = "./modules/iam"
  name_prefix = var.project
}

module "backend" {
  source                = "./modules/ec2"
  name                  = "${var.project}-backend"
  ami_id                = data.aws_ami.amzn2.id
  instance_type         = var.instance_type
  subnet_id             = module.vpc.private_subnet_id
  sg_ids                = [module.security.sg_backend_id]
  allocate_eip          = false
  instance_profile_name = module.iam_ssm.instance_profile_name
  depends_on            = [module.vpc, module.security, module.iam_ssm]
  tags                  = { Project = var.project }

  user_data = templatefile("${path.module}/templates/user_data_backend.sh.tftpl", {
    back_image   = var.back_image
    backend_port = var.backend_port
    database_url = var.database_url
    userdata_rev = var.userdata_rev
  })
}

module "frontend" {
  source                = "./modules/ec2"
  name                  = "${var.project}-frontend"
  ami_id                = data.aws_ami.amzn2.id
  instance_type         = var.instance_type
  subnet_id             = module.vpc.public_subnet_id
  sg_ids                = [module.security.sg_frontend_id]
  allocate_eip          = true
  instance_profile_name = module.iam_ssm.instance_profile_name
  depends_on            = [module.vpc, module.security, module.iam_ssm, module.backend]
  tags                  = { Project = var.project }


  user_data = templatefile("${path.module}/templates/user_data_frontend.sh.tftpl", {
    front_image        = var.front_image
    frontend_port      = var.frontend_port
    backend_private_ip = module.backend.private_ip
    backend_port       = var.backend_port
    userdata_rev       = var.userdata_rev
  })
}
