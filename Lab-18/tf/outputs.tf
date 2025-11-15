# Outputs

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "instance_a_id" {
  description = "Instance A ID"
  value       = aws_instance.instance_a.id
}

output "instance_a_public_ip" {
  description = "Instance A public IP"
  value       = aws_instance.instance_a.public_ip
}

output "instance_a_az" {
  description = "Instance A availability zone"
  value       = aws_instance.instance_a.availability_zone
}

output "instance_b_id" {
  description = "Instance B ID"
  value       = aws_instance.instance_b.id
}

output "instance_b_public_ip" {
  description = "Instance B public IP"
  value       = aws_instance.instance_b.public_ip
}

output "instance_b_az" {
  description = "Instance B availability zone"
  value       = aws_instance.instance_b.availability_zone
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "Application Load Balancer URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "alb_arn" {
  description = "Application Load Balancer ARN"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.main.arn
}

output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "EC2 Security Group ID"
  value       = aws_security_group.ec2.id
}
