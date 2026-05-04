provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
}

# Route
resource "aws_route" "r" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Route Table Association
resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

# Security Group
resource "aws_security_group" "sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux (us-east-1 safe)
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd

cat <<HTML > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Terraform AWS DevOps Project</title>
  <style>
    body {
      margin: 0;
      font-family: Arial, sans-serif;
      background: linear-gradient(135deg, #1f2937, #2563eb);
      color: white;
      text-align: center;
    }
    .container {
      margin-top: 120px;
    }
    .card {
      background: rgba(255, 255, 255, 0.12);
      padding: 40px;
      border-radius: 18px;
      width: 70%;
      margin: auto;
      box-shadow: 0 10px 25px rgba(0,0,0,0.3);
    }
    h1 {
      font-size: 42px;
      margin-bottom: 10px;
    }
    p {
      font-size: 20px;
      line-height: 1.6;
    }
    .badge {
      display: inline-block;
      margin-top: 20px;
      padding: 12px 22px;
      background: #22c55e;
      border-radius: 999px;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="card">
      <h1>🚀 Terraform AWS Infrastructure</h1>
      <p>Automated cloud infrastructure deployment using Terraform and GitHub Actions CI/CD.</p>
      <p>Provisioned VPC, Subnet, Internet Gateway, Security Group, and EC2 Web Server.</p>
      <div class="badge">Deployed Successfully via CI/CD</div>
    </div>
  </div>
</body>
</html>
HTML
EOF

# Output Public IP
output "public_ip" {
  value = aws_instance.web.public_ip
}
