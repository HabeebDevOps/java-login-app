output "global_ami_id" {
  description = "The ID of the created global AMI"
  value       = module.ami.ami_id
}

output "nginx_ami_id" {
  description = "The ID of the Nginx Golden AMI"
  value       = module.ami.nginx_ami_id
}

output "tomcat_ami_id" {
  description = "The ID of the Tomcat Golden AMI"
  value       = module.ami.tomcat_ami_id
}

output "maven_ami_id" {
  description = "The ID of the Maven Golden AMI"
  value       = module.ami.maven_ami_id
}

output "main_vpc_id" {
  value = module.main_vpc.vpc_id
}

output "support_vpc_id" {
  value = module.support_vpc.vpc_id
}

output "vpc_peering_id" {
  value = module.vpc_peering.peering_id
}