provider "aws" {
  region  = "us-east-1"
}

variable "sec-gr-mutual1" {
  default = "petclinic-k8s-mutual-sec-group1"
}

variable "sec-gr-k8s-master1" {
  default = "petclinic-k8s-master-sec-group1"
}


data "aws_vpc" "name" {
  default = true
}

resource "aws_security_group" "petclinic-mutual-sg1" {
  name = var.sec-gr-mutual1
  vpc_id = data.aws_vpc.name.id

  ingress {
    protocol = "tcp"
    from_port = 10250
    to_port = 10250
    self = true
  }

    ingress {
    protocol = "udp"
    from_port = 8472
    to_port = 8472
    self = true
  }

    ingress {
    protocol = "tcp"
    from_port = 2379
    to_port = 2380
    self = true
  }

}

resource "aws_security_group" "petclinic-kube-master-sg1" {
  name = var.sec-gr-k8s-master1
  vpc_id = data.aws_vpc.name.id

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 6443
    to_port = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 10257
    to_port = 10257
    self = true
  }

  ingress {
    protocol = "tcp"
    from_port = 10259
    to_port = 10259
    self = true
  }

  ingress {
    protocol = "tcp"
    from_port = 30000
    to_port = 32767
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "kube-master-secgroup"
  }
}


resource "aws_instance" "kube-master1" {
    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.petclinic-kube-master-sg1.id, aws_security_group.petclinic-mutual-sg1.id]
    key_name = "clarus"
    subnet_id = "subnet-0e20fa945e258324e"  # select own subnet_id of us-east-1a
    availability_zone = "us-east-1a"
    tags = {
        Name = "kube-master1"
        Project = "tera-kube-ans"
        Role = "master"
        Id = "1"
        environment = "dev"
    }
}

output kube-master-ip {
  value       = aws_instance.kube-master1.public_ip
  sensitive   = false
  description = "public ip of the kube-master"
}
