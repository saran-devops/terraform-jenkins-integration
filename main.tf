provider "aws" {
  region = var.AWS_REGION
}

resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
  description = "Allow ssh and standard http/https ports inbound and everything outbound"
  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}

resource "aws_instance" "terraformCM" {
  ami                    = var.AMIS[var.AWS_REGION]
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_traffic.id]
  key_name               = var.key_name
  count                  = var.instance_count
  tags = {
    Name = element(var.instance_tags, count.index)
  }
}
output "my_public_ip" {
  value = aws_instance.terraformCM.*.public_ip

}

