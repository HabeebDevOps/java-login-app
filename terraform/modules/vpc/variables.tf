variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "attach_nat_gateway" {
  description = "Whether to attach a NAT Gateway"
  type        = bool
}

variable "bastion_host" {
  description = "Whether to create a bastion host"
  type        = bool
}

variable "key_name" {
  description = "Key name for the bastion host"
  type        = string
}

variable "add_alb" {
  description = "Whether to add an ALB"
  type        = bool
}

variable "add_nlb" {
  description = "Whether to add an NLB"
  type        = bool
}

variable "private_subnet_names" {
  description = "List of suffixes for private subnets"
  type        = list(string)
}
