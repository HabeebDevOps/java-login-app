module "ami" {
  source = "./modules/ami"

  instance_type   = var.instance_type
  instance_name   = var.instance_name
  ami_name        = var.ami_name
  nginx_ami_name  = var.nginx_ami_name  # Name for the Nginx Golden AMI
  tomcat_ami_name = var.tomcat_ami_name # Name for the Tomcat Golden AMI
  maven_ami_name  = var.maven_ami_name  # Name for the Maven Golden AMI
}

# Create Main VPC
module "main_vpc" {
  source = "./modules/vpc"

  vpc_name             = var.vpc1_name
  vpc_cidr             = var.main_vpc_cidr
  azs                  = var.azs
  public_subnets       = var.main_public_subnets
  private_subnets      = var.main_private_subnets
  private_subnet_names = var.main_private_subnet_names
  attach_nat_gateway   = true
  bastion_host         = false
  key_name             = var.key_name
  add_alb              = true
  add_nlb              = true
}

# Create Support VPC
module "support_vpc" {
  source               = "./modules/vpc"
  vpc_name             = var.vpc2_name
  vpc_cidr             = var.support_vpc_cidr
  azs                  = var.azs
  public_subnets       = var.support_public_subnets
  private_subnets      = []
  private_subnet_names = []
  attach_nat_gateway   = false
  bastion_host         = true
  key_name             = var.key_name
  add_alb              = false
  add_nlb              = false
}

module "vpc_peering" {
  source              = "./modules/peering"
  vpc1_id             = module.main_vpc.vpc_id
  vpc2_id             = module.support_vpc.vpc_id
  vpc1_cidr           = var.main_vpc_cidr
  vpc2_cidr           = var.support_vpc_cidr
  vpc1_route_table_id = module.main_vpc.route_table_id
  vpc2_route_table_id = module.support_vpc.route_table_id
  vpc1_name           = var.vpc1_name
  vpc2_name           = var.vpc2_name
}
