data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical owner

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "main" {
  count                  = var.min_instances
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[count.index % var.private_subnet_count].id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              set -e
              # Remove fish shell if it exists and set bash as default
              usermod -s /bin/bash ec2-user || true
              EOF

  monitoring = true

  tags = {
    Name = format("%s-instance-%d", var.project_name, count.index + 1)
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_lb_target_group_attachment" "main" {
  count            = var.min_instances
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.main[count.index].id
  port             = 80
}

resource "aws_launch_template" "main" {
  name_prefix            = format("%s-lt-", var.project_name)
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -e
              usermod -s /bin/bash ec2-user || true
              EOF
  )

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = format("%s-asg-instance", var.project_name)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main" {
  name                      = format("%s-asg", var.project_name)
  vpc_zone_identifier       = aws_subnet.private[*].id
  target_group_arns         = [aws_lb_target_group.main.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_instances
  max_size         = var.max_instances
  desired_capacity = var.min_instances

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = format("%s-asg-instance", var.project_name)
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
