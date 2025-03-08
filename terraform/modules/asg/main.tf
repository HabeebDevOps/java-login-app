resource "aws_launch_configuration" "lc" {
  name          = "${var.asg_name}-lc"
  image_id      = var.ami_id
  instance_type = var.instance_type  
  security_groups = var.security_group_ids
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.lc.id
  vpc_zone_identifier  = var.subnets
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  health_check_type    = "EC2"
  health_check_grace_period = 300

  tags = [
    {
      key                 = "Name"
      value               = var.asg_name
      propagate_at_launch = true
    }
  ]
}

output "asg_id" {
  value = aws_autoscaling_group.asg.id
}