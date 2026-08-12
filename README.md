# DevOps Exercise

This Terraform project creates the AWS infrastructure requested in the ENG take-home exercise.

## What it creates

- One VPC using `10.0.0.0/16`
- Two public subnets and two private subnets across two Availability Zones
- An internet-facing Application Load Balancer in the public subnets
- HTTP and HTTPS listeners on the ALB
- A self-signed certificate imported into ACM for SSL termination
- One Amazon Linux 2023 EC2 instance in a private subnet
- Nginx on the EC2 instance
- One target group that forwards ALB traffic to Nginx
- The required ALB and EC2 security groups
- An S3 gateway endpoint so the private instance can install Nginx without NAT

## Assumptions

- The deployment uses `us-east-1` and the AWS CLI `default` profile.
- The first two available Availability Zones in the region are used.
- The EC2 instance type is `t3.micro`.
- The instance has no public IP and the private route table has no internet route.
- Amazon Linux 2023 package repositories use S3. A free S3 gateway endpoint is included only so the private instance can install Nginx without a NAT gateway.
- The certificate is self-signed, so HTTPS verification commands use `curl --insecure`.

## Prerequisites

- AWS Account
- AWS shared credential profiles or An IAM role
- Terraform 1.15.x
- Permission to create the resources in that account

## Deploy

```bash
terraform fmt -check
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Verify

Get the Terraform outputs:

```
terraform output
terraform output -raw alb_dns_name
terraform output -raw ec2_private_ip
```


## Verified result

- Terraform: `1.15.8`
- AWS provider: `6.58.0`
- TLS provider: `4.3.0`
- ALB DNS: `devops-exercise-alb-315893299.us-east-1.elb.amazonaws.com`
- EC2 private IP: `10.0.11.131`
- Target health: `healthy`
- HTTP test: passed and returned the Nginx exercise page
- HTTPS test: passed with `--insecure` and returned the Nginx exercise page

## Cleanup

```
terraform plan -destroy
terraform destroy
```
