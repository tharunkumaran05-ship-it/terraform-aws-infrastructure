# Terraform AWS Infrastructure Project

## Overview
This project provisions AWS infrastructure using Terraform.

## Resources Created
- VPC
- Subnet
- Internet Gateway
- Route Table
- Security Group
- EC2 Instance (Web Server)
- S3 Bucket
- Remote Backend (S3 + DynamoDB)

## Features
- Infrastructure as Code
- Automated EC2 provisioning
- Apache web server using user_data
- Secure SSH access
- Terraform state stored in S3
- State locking using DynamoDB

## Commands Used

```bash
terraform init
terraform plan
terraform apply
terraform destroy