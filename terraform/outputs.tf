output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.main.arn
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.main.name
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "access_url" {
  description = "NGINX access URL"
  value       = "https://${aws_lb.main.dns_name}/phrase"
}

output "private_instance_ips" {
  description = "Private IPs of EC2 instances"
  value       = aws_instance.main[*].private_ip
}

output "instance_ids" {
  description = "Instance IDs"
  value       = aws_instance.main[*].id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
  sensitive   = false
}
