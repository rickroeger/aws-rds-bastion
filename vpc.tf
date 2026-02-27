
##Reference: https://github.com/terraform-aws-modules/terraform-aws-vpc

module "vpc" {
  version = "v6.5.1"
  source  = "terraform-aws-modules/vpc/aws"

  name = format("vpc-%s-%s", var.app, var.environment)
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets
  database_subnets = var.vpc_database_subnets

  enable_nat_gateway = false
  enable_vpn_gateway = false
  single_nat_gateway = false

  public_subnet_tags = {
    Name = format("subnet-%s-%s-public", var.app, var.environment)
    type = "public"
  }
  private_subnet_tags = {
    Name = format("subnet-%s-%s-private", var.app, var.environment)
    type = "private"
  }
  tags = {
    Terraform   = "true"
    Environment = var.environment
    APP         = var.app
  }
}