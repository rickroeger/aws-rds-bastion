#main configuration
region      = "us-east-2"
app         = "bastion-app"
environment = "prd"
profile     = "mvp"

#network configs
cidr                = "192.168.0.0/20"
azs                 = ["us-east-2a", "us-east-2b", "us-east-2c"]
vpc_private_subnets = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"]
vpc_public_subnets  = ["192.168.3.0/24", "192.168.4.0/24", "192.168.5.0/24"]
vpc_database_subnets  = ["192.168.6.0/24", "192.168.7.0/24", "192.168.8.0/24"]

#DB configs
db_name  = "app"
username = "appadmin"
