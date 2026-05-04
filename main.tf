provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraform-vpc"
  }
}

# Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

# Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
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
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux (us-east-1)
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data_replace_on_change = true
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
  <title>DevOps Project</title>
  <style>
    body {
      margin: 0;
      font-family: Arial;
      background: linear-gradient(135deg, #1e3a8a, #0f172a);
      color: white;
      text-align: center;
    }
    .card {
      margin-top: 120px;
      background: rgba(255,255,255,0.1);
      padding: 40px;
      border-radius: 15px;
      width: 60%;
      margin-left: auto;
      margin-right: auto;
    }
    h1 {
      font-size: 40px;
    }
    p {
      font-size: 20px;
    }
    .tag {
      margin-top: 20px;
      background: #22c55e;
      padding: 10px 20px;
      border-radius: 50px;
      display: inline-block;
    }
  </style>
</head>
<body>
  <div class="card">
    <h1>🚀 Terraform + GitHub Actions</h1>
    <p>AWS Infrastructure fully automated using CI/CD</p>
    <p>VPC | EC2 | Security Group | Internet Gateway</p>
    <p>Built by Tharun 🚀</p>
    <div class="tag">Deployment Successful</div>
    <br><br>
<a href="https://github.com/tharunkumaran05-ship-it/terraform-aws-infrastructure" target="_blank" style="color:white; background:#111827; padding:12px 22px; border-radius:30px; text-decoration:none; font-weight:bold;">
  View GitHub Repository
</a>
  </div>
</body>
</html>
HTML
EOF

  tags = {
    Name = "terraform-ec2"
  }
}
