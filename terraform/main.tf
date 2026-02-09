
#TERRAFORM SETTINGS
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


#CONFIGURING AWS PROVIDER
provider "aws" {
  region     = "ap-south-1"      
  }

#################################
#CONFIGURING DEFAULT VPC
#################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#################################
##CONFIGURING DEFAULT SECURITY GROUP
#################################

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

#################################
#CREATING LAUNCH TEMPLATE
#################################

resource "aws_launch_template" "nginx_lt" {
  name_prefix   = "nginx-template"
  image_id      = "ami-019715e0d74f695be"
  instance_type = "t2.micro"

  vpc_security_group_ids = [data.aws_security_group.default.id]

  user_data = base64encode(<<EOF
#!/bin/bash
yum install nginx -y
systemctl start nginx
systemctl enable nginx
EOF
)
}

#################################
##CREATING APPLICATION LOAD BALANCER
#################################

resource "aws_lb" "nginx_alb" {
  name               = "nginx-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [data.aws_security_group.default.id]
}

#################################
##CREATING TARGET GROUP
#################################

resource "aws_lb_target_group" "nginx_tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

#################################
#CREATING LISTENING PORT AND CONFIGURING IT TO PORT 80
#################################

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.nginx_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

#################################
#CREATING AUTO SCALING GROUP FOR 2 SERVERS
#################################

resource "aws_autoscaling_group" "nginx_asg" {

  desired_capacity    = 2
  min_size            = 2
  max_size            = 2

  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns   = [aws_lb_target_group.nginx_tg.arn]

  launch_template {
    id      = aws_launch_template.nginx_lt.id
    version = "$Latest"
  }
}

