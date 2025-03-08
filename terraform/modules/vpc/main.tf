# Create VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true  
  availability_zone       = element(var.azs, count.index)

  tags = {
    Name = "${var.vpc_name}-public-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.vpc_name}-${element(var.private_subnet_names, count.index)}"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-route-table"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# NAT Gateway
resource "aws_eip" "nat" {
  count  = var.attach_nat_gateway ? 1 : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  count  = var.attach_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.vpc_name}-nat"
  }
}

resource "aws_instance" "bastion" {
  count                 = var.bastion_host ? 1 : 0
  ami                   = "ami-091f18e98bc129c4e"  # Replace with a valid AMI ID for your region
  instance_type         = "t2.micro"
  subnet_id             = element(aws_subnet.public.*.id, 0)
  associate_public_ip_address = true
  key_name              = var.key_name

  tags = {
    Name = "${var.vpc_name}-bastion"
  }
}

resource "aws_lb" "alb" {
  count               = var.add_alb ? 1 : 0
  name                = "${var.vpc_name}-alb"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = [aws_security_group.lb_sg.id]
  subnets             = aws_subnet.public[*].id

  tags = {
    Name = "${var.vpc_name}-alb"
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  count     = var.add_alb ? 1 : 0
  name      = "${var.vpc_name}-tg"
  port      = 80
  protocol  = "HTTP"
  vpc_id    = aws_vpc.this.id

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "${var.vpc_name}-tg"
  }
}

resource "aws_lb_listener" "alb_listener" {
  count               = var.add_alb ? 1 : 0
  load_balancer_arn   = element(aws_lb.alb.*.arn, 0)
  port                = 80
  protocol            = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.alb_target_group.*.arn, 0)
  }
}

resource "aws_lb" "nlb" {
  count               = var.add_nlb ? 1 : 0
  name                = "${var.vpc_name}-nlb"
  internal            = true
  load_balancer_type  = "network"
  subnets = [for idx, name in var.private_subnet_names : aws_subnet.private[idx].id if name == "Tomcat"]

  enable_deletion_protection = false


  tags = {
    Name = "${var.vpc_name}-nlb"
  }
}

resource "aws_lb_target_group" "nlb_target_group" {
  count     = var.add_nlb ? 1 : 0
  name      = "${var.vpc_name}-nlb-tg"
  port      = 8080
  protocol  = "TCP"
  vpc_id    = aws_vpc.this.id

  health_check {
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "${var.vpc_name}-nlb-tg"
  }
}

resource "aws_lb_listener" "nlb_listener" {
  count               = var.add_nlb ? 1 : 0
  load_balancer_arn   = element(aws_lb.nlb.*.arn, 0)
  port                = 8080
  protocol            = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.nlb_target_group.*.arn, 0)
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "${var.vpc_name}-lb-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-lb-sg"
  }
}

