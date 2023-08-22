






resource "aws_instance" "web" {
  ami                     = var.ami
  instance_type           = var.instance_type
  security_groups = [aws_security_group.vpc1-sg.id]
  key_name                = aws_key_pair.key1.key_name
  subnet_id               = aws_subnet.pub-sub.id
  tags                    = {
    Name = var.tags

  }
}

resource "aws_key_pair" "key1" {
  key_name   = "key-${terraform.workspace}"
  public_key = file("${path.module}/.id_rsa.pub")
   tags                    = {
    Name = var.tags

  }
}

resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc_cidr_block
 tags                    = {
    Name = var.tags

  }
}

resource "aws_subnet" "pub-sub" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.public-subnet_id
  availability_zone = var.availability_zone[0]
  tags                    = {
    Name = var.tags

  }
}


resource "aws_subnet" "pvt-sub" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.private-subnet_id
  availability_zone = var.availability_zone[1]
  tags                    = {
    Name = var.tags

  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id
  tags                    = {
    Name = var.tags

  }
}

resource "aws_eip" "eip-nat" {
 domain = "vpc"
}

resource "aws_eip" "eip-instance" {
 instance = aws_instance.web.id
 domain = "vpc"
}
 


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip-nat.id
  subnet_id     = aws_subnet.pub-sub.id
  tags                    = {
    Name = var.tags

  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
   tags                    = {
    Name = var.tags

  }
}  
  
resource "aws_route_table" "pvt-rt" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
    tags                    = {
    Name = var.tags

  }
}

resource "aws_route_table_association" "pub-rt-asso" {
  subnet_id      = aws_subnet.pub-sub.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "pvt-rt-asso" {
  subnet_id      = aws_subnet.pvt-sub.id
  route_table_id = aws_route_table.pvt-rt.id
}


#security_group

resource "aws_security_group" "vpc1-sg" {
  name        = "${terraform.workspace}-sg"
  vpc_id      = aws_vpc.vpc1.id
  tags        = {
    Name    = var.tags
  }


dynamic "ingress" {
    for_each = var.port
    iterator = port
    content {
      description      = "TLS from VPC"
      from_port        = port.value
      to_port          = port.value
      protocol         = "tcp"
      cidr_blocks      = [var.vpc_cidr_block]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 
}





