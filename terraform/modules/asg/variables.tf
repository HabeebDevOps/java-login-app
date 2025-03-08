variable "ami_id" {
  description = "AMI ID for the instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the ASG"
  type        = string
}

variable "asg_name" {
  description = "Name for the ASG"
  type        = string
}

variable "subnets" {
  description = "Subnets for the ASG"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the instances"
  type        = list(string)
}

variable "min_size" {
  description = "Minimum size of the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired capacity of the ASG"
  type        = number
  default     = 2
}