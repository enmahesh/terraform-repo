provider "aws" {
  region = "us-east-1"  
  
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = "11.0.0.0/16"
  enable_dns_support = true 
    enable_dns_hostnames = true
    tags = {
        Name = "myapp-vpc"  
}
}


resource "aws_subnet" "myapp-subnet" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = "11.0.10.0/24"
  availability_zone = "us-east-1a"
    map_public_ip_on_launch = true  
    tags = {
        Name = "myapp-subnet"  
    }     
}


resource "aws_internet_gateway" "myapp-gateway" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name = "myapp-gateway"
  }     
}
resource   "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name = "myapp-route-table"
  }     

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-gateway.id      
    }   
}             


resource "aws_route_table_association" "a-rtb-ass" {
    subnet_id = aws_subnet.myapp-subnet.id
    route_table_id = aws_route_table.myapp-route-table.id
}

resource "aws_security_group" "my_app_sg" {
    name     = "my_app_sg"
    description = "Security group for my app"   
    vpc_id      = aws_vpc.myapp-vpc.id
    tags = {
        Name = "my_app_sg"
    }

    ingress{
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            cidr_blocks = ["202.166.217.75/32"]
            description = "SSH access from specific IP"
        }

       ingress {
            from_port   = 8080
            to_port     = 8080
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            description = "HTTP access from anywhere"       
        }
        
        egress {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            description = "Allow all outbound traffic"  
        }           
    }

