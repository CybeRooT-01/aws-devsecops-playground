variable "cidr_block" {}
variable "public_subnet_cidr" {}
variable "name" {}
variable "az" {default = "eu-north-1a" }
variable "private_subnet_cidr_1" {
  description = "CIDR block pour le premier subnet privé"
  type        = string
  default     = "10.20.10.0/24"
}
variable "private_subnet_cidr_2" {
  description = "CIDR block pour le deuxième subnet privé"
  type        = string
  default     = "10.20.11.0/24"
}
