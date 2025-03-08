variable "vpc1_name" {
  description = "Name of the first VPC"
  type        = string
}

variable "vpc2_name" {
  description = "Name of the second VPC"
  type        = string
}

variable "vpc1_id" {
  description = "ID of the first VPC"
  type        = string
}

variable "vpc2_id" {
  description = "ID of the second VPC"
  type        = string
}

variable "vpc1_cidr" {
  description = "CIDR block of the first VPC"
  type        = string
}

variable "vpc2_cidr" {
  description = "CIDR block of the second VPC"
  type        = string
}

variable "vpc1_route_table_id" {
  description = "Route table ID of the first VPC"
  type        = string
}

variable "vpc2_route_table_id" {
  description = "Route table ID of the second VPC"
  type        = string
}
