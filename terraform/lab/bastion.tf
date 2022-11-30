data "aws_ami" "al2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

resource "tls_private_key" "bastion_linux" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_linux" {
  key_name   = "${var.env_name}-BASTION-LINUX-1A"
  public_key = tls_private_key.bastion_linux.public_key_openssh
}

resource "aws_security_group" "bastion_linux" {
  name        = "${var.env_name}-BASTION-LINUX-1A-sg"
  description = "Bastion Host Linux Security Group"
  vpc_id      = module.prod_vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "bastion_linux" {
  ami                     = data.aws_ami.al2.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  instance_type           = "t3a.small"
  subnet_id               = module.prod_subnet_public[1].id
  private_ip              = "10.14.0.10"
  iam_instance_profile    = aws_iam_instance_profile.bastion_linux.id
  key_name                = aws_key_pair.bastion_linux.key_name
  monitoring              = false
  disable_api_termination = true

  vpc_security_group_ids = [
    aws_security_group.bastion_linux.id
  ]

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = false
  }

#   metadata_options {
#     http_endpoint               = "enabled"
#     http_put_response_hop_limit = 2
#     http_tokens                 = "required"
#   }

  tags = merge(local.tags, {
    Name = "${var.env_name}-BASTION-LINUX-1A"
  })

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

resource "aws_eip" "bastion_linux" {
  vpc      = true
  instance = aws_instance.bastion_linux.id
}
