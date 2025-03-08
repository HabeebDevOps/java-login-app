output "ami_id" {
  description = "The ID of the created AMI"
  value       = aws_ami_from_instance.global_ami.id
}

output "instance_id" {
  description = "The ID of the base instance"
  value       = aws_instance.base_instance.id
}

output "nginx_ami_id" {
  description = "The ID of the Nginx Golden AMI"
  value       = aws_ami_from_instance.nginx_ami.id
}

output "tomcat_ami_id" {
  description = "The ID of the Tomcat Golden AMI"
  value       = aws_ami_from_instance.tomcat_ami.id
}

output "maven_ami_id" {
  description = "The ID of the Maven Golden AMI"
  value       = aws_ami_from_instance.maven_ami.id
}