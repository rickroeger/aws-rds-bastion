locals {
  instance_type = "t3.micro"
  ports_tcp_all = ["23","80","8080","443"]
}


module "instance_bastion" {
  version = "v6.1.5"
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = format("%s-%s-instance", var.app, var.environment)

  ami = data.aws_ami.ubuntu.id

 # user_data = templatefile("${path.module}/scripts/cloud-init-master.sh", {
 #   NODE_MASTER    = var.master_first_node,
 #   SECRET_MANAGER = aws_secretsmanager_secret.k3s_token.arn,
 #   FIST_NODE      = true
 # })


  instance_type               = local.instance_type
  key_name                    = module.instance_key_pair.key_pair_name
  monitoring                  = true
  subnet_id                   = module.vpc.public_subnets[0]
  create_eip = true
  create_iam_instance_profile = true
  iam_role_description        = format("IAM role for EC2 instance %s-%s-instance",var.app, var.environment)
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AWSSecretsManagerClientReadOnlyAccess = "arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess"
  }
  vpc_security_group_ids = [aws_security_group.allow_rds.id, aws_security_group.allow_instance.id]

  root_block_device = {
    size                  = 10
    delete_on_termination = true
    type                  = "gp3"
    encrypted             = true
  }
  ebs_volumes = {
    "/dev/sdf" = {
      size                  = 20 # GB
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
      tags = {
        MountPoint = "/var/lib/data"
      }
    }
  }

  tags = {
    Terraform   = "true"
    Environment = var.environment
    APP         = var.app
  }
}

resource "aws_security_group" "allow_rds" {
  vpc_id      = module.vpc.vpc_id
  description = "Security group to allow k3s traffic."
  name        = format("%s-%s-k3s-sg", lower(var.app), var.environment)
  tags = {
    Name        = format("%s-%s-k3s-sg", lower(var.app), var.environment)
    Terraform   = "true"
    Environment = var.environment
    APP         = var.app
  }
}

resource "aws_security_group" "allow_instance" {
  vpc_id      = module.vpc.vpc_id
  description = "Security group for instace nodes."
  name        = format("%s-%s-instance-sg", lower(var.app), var.environment)

  dynamic "ingress" {
    for_each = local.ports_tcp_all
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = format("sg-%s-%s-instance", lower(var.app), var.environment)
    Terraform   = "true"
    Environment = var.environment
    APP         = var.app
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

##ref: https://github.com/terraform-aws-modules/terraform-aws-key-pair
module "instance_key_pair" {
  version = "v2.1.1"
  source  = "terraform-aws-modules/key-pair/aws"

  key_name           = format("kp-%s-%s-instance", var.app, var.environment)
  create_private_key = true
}