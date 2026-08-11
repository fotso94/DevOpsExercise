output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "ec2_private_ip" {
  description = "Private IP address of the Nginx EC2 instance"
  value       = aws_instance.web.private_ip
}
