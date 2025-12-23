resource "aws_launch_template" "lt" {
  name_prefix   = "ecommerce-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  security_group_names = [aws_security_group.ec2_sg.name]

  user_data = base64encode(<<EOF
#!/bin/bash
yum install -y httpd
systemctl start httpd
echo "E-Commerce App" > /var/www/html/index.html
EOF
)
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  vpc_zone_identifier  = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
}