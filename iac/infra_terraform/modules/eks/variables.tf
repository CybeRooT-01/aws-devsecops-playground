variable "cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
}

variable "cluster_version" {
  description = "Version du cluster EKS"
  type        = string
  default     = "1.30"
}

variable "cluster_endpoint_public_access" {
  description = "Activer l'accès public au endpoint du cluster"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID du VPC où déployer le cluster EKS"
  type        = string
}

variable "subnet_ids" {
  description = "Liste des IDs des subnets privés pour le cluster EKS"
  type        = list(string)
}

variable "node_min_size" {
  description = "Nombre minimum de nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Nombre maximum de nodes"
  type        = number
  default     = 4
}

variable "node_desired_size" {
  description = "Nombre désiré de nodes"
  type        = number
  default     = 2
}

variable "node_instance_type" {
  description = "Type d'instance pour les nodes EKS"
  type        = string
  default     = "c7i-flex.large"
}

variable "node_capacity_type" {
  description = "Type de capacité pour les nodes (ON_DEMAND ou SPOT)"
  type        = string
  default     = "SPOT"
}

variable "node_tags" {
  description = "Tags à appliquer aux nodes"
  type        = map(string)
  default = {
    ExtraTag = "cyber_Node"
  }
}

variable "tags" {
  description = "Tags à appliquer aux ressources EKS"
  type        = map(string)
  default     = {}
}

