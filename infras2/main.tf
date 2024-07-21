# main.tf
# Generate SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Output the private key
output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

# Save file
resource "local_file" "ssh_key" {
  filename = "terraform_ssh_key.pem"
  content  = tls_private_key.ssh_key.private_key_pem
}

# Create a security group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

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

# Create Ubuntu instance with Ansible installed
resource "aws_instance" "ubuntu_with_ansible" {
  ami                    = "ami-04a81a99f5ec58529" # Ubuntu AMI ID
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install ansible -y
              echo "${tls_private_key.ssh_key.public_key_openssh}" >> ~/.ssh/authorized_keys
              EOF

  tags = {
    Name = "UbuntuWithAnsible"
  }
}

# Create second Ubuntu instance
resource "aws_instance" "ubuntu" {
  ami                    = "ami-04a81a99f5ec58529" # Ubuntu AMI ID
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Ubuntu"
  }
}

# Create Red Hat instance
resource "aws_instance" "redhat" {
  ami                    = "ami-0a313d6098716f372" # Red Hat AMI ID
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "RedHat"
  }
}

# Create Debian instance
resource "aws_instance" "debian" {
  ami                    = "ami-00402f0bdf4996822" # Debian AMI ID
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "Debian"
  }
}

# Generate SSH key pair in AWS
resource "aws_key_pair" "generated_key" {
  key_name   = "terraform_ssh_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

output "public_ip_ubuntu_with_ansible" {
  value = aws_instance.ubuntu_with_ansible.public_ip
}

output "public_ip_ubuntu" {
  value = aws_instance.ubuntu.public_ip
}

output "public_ip_redhat" {
  value = aws_instance.redhat.public_ip
}

output "public_ip_debian" {
  value = aws_instance.debian.public_ip
}
