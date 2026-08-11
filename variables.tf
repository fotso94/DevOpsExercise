variable "aws_region" {
  description = "AWS region used for the exercise"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for the Nginx server"
  type        = string
  default     = "t3.micro"
}
