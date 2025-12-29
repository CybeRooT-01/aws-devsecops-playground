variable "subnet_id" {}
variable "sg_id" {}
variable "instance_type" {}
variable "name" {}

variable "key_name" {
	description = "Name of the AWS key pair to attach to the instance"
	default     = null
}
