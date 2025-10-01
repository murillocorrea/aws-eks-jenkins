# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.vpc_cidr

  azs            = data.aws_availability_zones.azs.names
  public_subnets = var.public_subnets
  map_public_ip_on_launch = false

  enable_dns_hostnames = true

  tags = {
    Name        = "jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
    Name      = "jenkins-public-subnet-1"
    Terraform = "true"
  }
}

# SG
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "http"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "all traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  
  tags = {
    Name      = "jenkins-sg"
    Terraform = "true"
  }
}

# EC2
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-server"

  instance_type = var.instance_type
  key_name      = "jenkins-server-keypair"
  monitoring    = true
  vpc_security_group_ids = [module.sg.security_group_id]
  subnet_id     = module.vpc.public_subnets[0]
  associate_public_ip_address = false
  user_data = file("jenkins-install.sh")
  availability_zone = data.aws_availability_zones.azs.names[0]
  
  tags = {
    Name       = "jenkins-server"
    Terraform   = "true"
    Environment = "dev"
  }
}

# Elastic IP
  resource "aws_eip" "jenkins_eip" {
  instance = module.ec2_instance.id
  domain = "vpc"

 tags = {
    Name      = "jenkins-eip"
    Terraform = "true"
  }
}



