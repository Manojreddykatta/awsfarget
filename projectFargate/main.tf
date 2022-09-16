resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support= true
  enable_dns_hostnames= true
  tags = {
    Name = "mahiinternalVPC"
  }
}
resource "aws_subnet" "public" {
    count = length(var.subnet_cidrs_public)
    vpc_id     = aws_vpc.vpc.id
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = "true"
    cidr_block = var.subnet_cidrs_public[count.index]
    tags = {
        Name = format("Publicmahiinternal-%g",count.index)
    }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "mahiinternalIGW"
  }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id  
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      Name = "mahiPublicRoute"
    }
}

resource "aws_route_table_association" "public" {
  count = length(var.subnet_cidrs_public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "eip" {
    vpc      = true
    depends_on = [aws_internet_gateway.igw]
    tags = {
        Name ="mahiEIPinternal"
    }
}

resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.eip.id
    subnet_id     = aws_subnet.public[0].id  
    tags = {
      Name = "NATmahiinternal"
     }
}

resource "aws_subnet" "private" {
    count = length(var.subnet_cidrs_public)
    vpc_id     = aws_vpc.vpc.id
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = "false"
    cidr_block = var.subnet_cidrs_private[count.index]
    tags = {
        Name = format("Privatemahiinternal-%g",count.index)
    }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = "Routeprivatemahiinternal"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.subnet_cidrs_private)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "sg" {
  name        = "internalmahi-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
   ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   }

  

  tags = {
    Name = "internalmahi-sg"
  }

}
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name               = "mahiAlbinternal"
  internal           = false
  security_groups    = [aws_security_group.sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  enable_deletion_protection = false
   tags = {
    Environment = "mahiAlbinternal"
  }
}

resource "aws_lb_target_group" "target_group" {
   

  name        = "mahi-target-group"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/"
    interval            = 30
  }
}
  
#   resource "aws_lb_target_group_attachment" "target_group_attachment" {
     

#    target_group_arn = aws_lb_target_group.target_group.arn
#    target_id        = aws_ecs_service.ecs.id
#    port             = 80
#  }
#   resource "aws_lb_target_group_attachment" "target_group_attachment_lb" {
     

#   target_group_arn = aws_lb_target_group.target_group.arn
#   target_id        = aws_lb.alb.id
#   port             = 80
# }



















































