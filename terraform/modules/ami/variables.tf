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