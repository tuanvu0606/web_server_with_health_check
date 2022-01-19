
# ------------------------------------------------------- VPC ------------------------------------------------------------- #

resource "aws_vpc" "challenge_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Challenge_VPC"
  }
}

# ------------------------------------------------------- Internet Gateway ------------------------------------------------------------- #

resource "aws_internet_gateway" "challenge_internet_gateway" {
  vpc_id = aws_vpc.challenge_vpc.id
}

# ------------------------------------------------------- Route Table ------------------------------------------------------------- #

resource "aws_route_table" "challenge_route_table" {
  vpc_id = aws_vpc.challenge_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.challenge_internet_gateway.id
  }

  tags = {
    Name = "Challenge route table"
  }
}

resource "aws_main_route_table_association" "challenge_main_route_table" {
  vpc_id         = aws_vpc.challenge_vpc.id
  route_table_id = aws_route_table.challenge_route_table.id
}

# ---------------------------------------------------- Subnets ------------------------------------------------------------- #

resource "aws_subnet" "challenge_southeast_public_subnet" {
  vpc_id     = aws_vpc.challenge_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  
  tags = {
    Name = "192.168.1.0-30-southeast_challenge_public_subnet"
  }
}

# ---------------------------------------------------- Security Group ------------------------------------------------------------- #

resource "aws_security_group" "challenge_public_asg" {
  name        = "ChallengePublicASG"
  description = "Public ASG"
  vpc_id      = aws_vpc.challenge_vpc.id

ingress = [
  {
    cidr_blocks      = ["0.0.0.0/0",]
    description      = ""
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
  },
  {
    cidr_blocks      = ["0.0.0.0/0",]
    description      = ""
    from_port        = 80
    ipv6_cidr_blocks = ["::/0",]
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 80
  } 
]

  egress = [
  {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  },
]

  tags = {
    Name = "Public ASG"
  }
}

# ---------------------------------------------------- Network Interfaces ------------------------------------------------------------- #

resource "aws_network_interface" "challenge_network_interface" {
  subnet_id   = aws_subnet.challenge_southeast_public_subnet.id
  private_ips = ["10.0.1.6"]
  security_groups = [aws_security_group.challenge_public_asg.id]

  tags = {
    Name = "challenge_network_interface"
  }
}

# ---------------------------------------------------- EC2 Instance ------------------------------------------------------------- #

resource "tls_private_key" "challenge_tpk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "challenge_akp" {
  key_name   = var.key_name
  public_key = tls_private_key.challenge_tpk.public_key_openssh
}

resource "aws_instance" "challeng_ec2" {
  ami                     = "ami-07315f74f3fa6a5a3" # us-west-2  
  instance_type           = "t2.micro"
  key_name                = aws_key_pair.challenge_akp.key_name
  tenancy                 = "default"

  root_block_device {
    volume_type = "standard"
    volume_size = "10"
  }

  network_interface {
    network_interface_id = aws_network_interface.challenge_network_interface.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "standard"
  }

  lifecycle {
    create_before_destroy = false
  }
  
  user_data = <<-EOF
              #!/bin/bash
              ASD="asdas"
              mkdir ~/testing_folder
              MEO="asdasdssa"
              sudo apt update -y
              sudo apt install apache2 -y
              EOF

  tags = {
    Name = "challeng_ec2"
  }
}
