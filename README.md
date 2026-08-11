# DevOps Exercise

This Terraform project creates the AWS infrastructure requested in the Cloud Infrastructure ENG take-home exercise.

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
- No SSH key pair is created. The security group includes the required SSH rule from the VPC CIDR, but direct internet SSH access is not possible.

## Prerequisites

- AWS CLI v2 configured with a `default` profile
- Terraform 1.15.x
- Permission to create the resources in this project

Check the active account and region:

```bash
aws --version
aws sts get-caller-identity --profile default
aws configure get region --profile default
terraform version
```

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

```bash
terraform output
terraform output -raw alb_dns_name
terraform output -raw ec2_private_ip
```

Test HTTP and HTTPS:

```powershell
$ALB_DNS = terraform output -raw alb_dns_name
curl.exe --fail "http://$ALB_DNS"
curl.exe --fail --insecure "https://$ALB_DNS"
```

Check the target health:

```powershell
$TARGET_GROUP_ARN = aws elbv2 describe-target-groups `
  --names devops-exercise-tg `
  --query 'TargetGroups[0].TargetGroupArn' `
  --output text

aws elbv2 describe-target-health `
  --target-group-arn $TARGET_GROUP_ARN
```

## Verified result

Automated verification completed successfully in `us-east-1` on August 11, 2026.

- AWS CLI: `2.36.21`
- Terraform: `1.15.8`
- AWS provider: `6.58.0`
- TLS provider: `4.3.0`
- ALB DNS: `devops-exercise-alb-315893299.us-east-1.elb.amazonaws.com`
- EC2 private IP: `10.0.11.131`
- Target health: `healthy`
- HTTP test: passed and returned the Nginx exercise page
- HTTPS test: passed with `--insecure` and returned the Nginx exercise page
- Final Terraform plan: `No changes. Your infrastructure matches the configuration.`

The checks also confirmed four subnets across two Availability Zones, no public IP on the EC2 instance, no internet route in the private route table, the required security-group rules, and HTTP/HTTPS listeners on ports 80 and 443.

## Cleanup

Cleanup is destructive. Review the plan before confirming:

```bash
terraform plan -destroy
terraform destroy
```

Do not delete the Terraform state before running `terraform destroy`.
