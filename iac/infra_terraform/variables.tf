variable "region" { default = "eu-north-1" }

variable "aws_profile" {
  description = "Profil AWS CLI à utiliser (défini dans ~/.aws/credentials)"
  type        = string
  default     = "default"
}

variable "instance_type" { default = "c7i-flex.large" }

variable "key_name" {
  description = "Nom du key pair AWS à associer aux instances"
  type        = string
  default     = "devSecOps"
}

# Variables liées au module EKS

variable "eks_cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
  default     = "devsecops-eks"
}

variable "eks_node_instance_type" {
  description = "Type d'instance pour les nodes EKS"
  type        = string
  default     = "c7i-flex.large"
}

variable "eks_node_min_size" {
  description = "Nombre minimum de nodes"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Nombre maximum de nodes"
  type        = number
  default     = 4
}

variable "eks_node_desired_size" {
  description = "Nombre désiré de nodes"
  type        = number
  default     = 2
}
