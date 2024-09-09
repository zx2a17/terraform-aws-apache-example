

#google terraform, data source, vpc to find this block of example
data "aws_vpc" "main" {
  id = var.vpc_id
}


#look on terraform registery to look for security group to find example of how to do this
resource "aws_security_group" "sg_terra_assoc" {
  name        = "sg_terra_assoc"
  description = "my-server-sg"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "sg_terra_assoc"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_port80" {
  security_group_id = aws_security_group.sg_terra_assoc.id
  #cidr_ipv4         = data.aws_vpc.main.cidr_block
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp" #to install apache
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_port22" {
  security_group_id = aws_security_group.sg_terra_assoc.id
  #cidr_ipv4         = data.aws_vpc.main.cidr_block
  cidr_ipv4   = var.my_ip_with_cidr
  from_port   = 22
  ip_protocol = "tcp" #to install apache
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg_terra_assoc.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key

}

data "template_file" "user_data" {
  template = file("${abspath(path.module)}/userdata.yaml")
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


data "aws_subnets" "subnet_ids" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  //vpc_id = data.aws_vpc.main.id
}

resource "aws_instance" "my_server" {
  ami                    = data.aws_ami.ubuntu.id
  subnet_id = data.aws_subnets.subnet_ids.ids[0]
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg_terra_assoc.id]
  user_data              = data.template_file.user_data.rendered

  tags = {
    Name = var.server_name
  }
}

