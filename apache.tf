provider "aws" {
  region  = "us-east-1"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_security_group" "apache_allow_http_ssh" {
  name        = "apache_allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic to apache"

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
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                         = "${data.aws_ami.amazon-linux-2.id}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  security_groups             = ["${aws_security_group.apache_allow_http_ssh.name}"]
  key_name                    = "MyAmazonPrivateKey"
  user_data                   = "${file("./apache.sh")}"

  tags = {
    Name = "Apache"
  }
}

output "IP" {
  value = "${aws_instance.web.public_ip}"
}