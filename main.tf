provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
}

module "rds" {
  source             = "./modules/rds"
  private_subnet_ids = module.vpc.private_subnet_ids
  db_sg_id           = module.vpc.db_sg_id
}

module "efs" {
  source             = "./modules/efs"
  private_subnet_ids = module.vpc.private_subnet_ids
  efs_sg_id          = module.vpc.efs_sg_id
}

module "network" {
  source            = "./modules/network"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.vpc.alb_sg_id
  domain_name       = var.domain_name
}

module "compute" {
  source             = "./modules/compute"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  app_sg_id          = module.vpc.app_sg_id
  efs_id             = module.efs.efs_id
  db_endpoint        = module.rds.db_endpoint
  db_secret_arn      = module.rds.secret_arn
  tg_arn             = module.network.target_group_arn
  region             = var.region
}

module "monitoring" {
  source   = "./modules/monitoring"
  asg_name = module.compute.asg_name
  region   = var.region
  db_instance_identifier = module.rds.db_id 
}
