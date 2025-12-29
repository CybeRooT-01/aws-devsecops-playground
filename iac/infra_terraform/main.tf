terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

module "vpc" {
  source                = "./modules/vpc"
  cidr_block            = "10.20.0.0/16"
  public_subnet_cidr    = "10.20.1.0/24"
  private_subnet_cidr_1 = "10.20.10.0/24"
  private_subnet_cidr_2 = "10.20.11.0/24"
  name                  = "jenkins-vpc"
  az                    = "eu-north-1a"
}

module "sg" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  name   = "jenkins-sg"
}

module "jenkins_master" {
  source           = "./modules/ec2"
  subnet_id        = module.vpc.public_subnet_id
  sg_id            = module.sg.sg_id
  instance_type    = var.instance_type
  name             = "jenkins-master"
  key_name         = var.key_name
}

/*module "jenkins_agent" {
  source           = "./modules/ec2"
  subnet_id        = module.vpc.public_subnet_id
  sg_id            = module.sg.sg_id
  instance_type    = var.instance_type
  name             = "jenkins-agent"
  key_name         = var.key_name
}
*/

module "eks" {
  source = "./modules/eks"

  cluster_name                   = var.eks_cluster_name
  cluster_version                = "1.30"
  cluster_endpoint_public_access  = true
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnet_ids

  node_min_size     = var.eks_node_min_size
  node_max_size     = var.eks_node_max_size
  node_desired_size = var.eks_node_desired_size
  node_instance_type = var.eks_node_instance_type
  node_capacity_type = "SPOT"

  node_tags = {
    ExtraTag = "cyber_Node"
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Cluster     = var.eks_cluster_name
  }
}