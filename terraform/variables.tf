variable "instance_type" {
  description = "Instance type for the base instance"
  type        = string
}

variable "instance_name" {
  description = "Tag name for the instance"
  type        = string
}

variable "ami_name" {
  description = "Name for the generated AMI"
  type        = string
}

variable "nginx_ami_name" {
  description = "Name for the Nginx Golden AMI"
  type        = string
}

variable "tomcat_ami_name" {
  description = "Name for the Tomcat Golden AMI"
  type        = string
}

variable "maven_ami_name" {
  description = "Name for the maven Golden AMI"
  type        = string
}

variable "main_vpc_cidr" {
  description = "CIDR block for the main VPC"
  type        = string
}

variable "support_vpc_cidr" {
  description = "CIDR block for the support VPC"
  type        = string
}

variable "main_public_subnets" {
  description = "CIDR blocks for public subnets in the main VPC"
  type        = list(string)
}

variable "main_private_subnets" {
  description = "CIDR blocks for private subnets in the main VPC"
  type        = list(string)
}

variable "main_private_subnet_names" {
  description = "List of suffixes for private subnets"
  type        = list(string)
}

variable "support_public_subnets" {
  description = "CIDR blocks for public subnets in the support VPC"
  type        = list(string)
}

variable "azs" {
  description = "Availability zones for the subnets"
  type        = list(string)
}

variable "vpc1_name" {
  description = "Name of the first VPC"
  type        = string
}

variable "vpc2_name" {
  description = "Name of the second VPC"
  type        = string
}

variable "key_name" {
  description = "Key name for the bastion host"
  type        = string
}