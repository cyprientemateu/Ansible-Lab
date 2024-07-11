# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {
}

# Create Web Security Group
resource "aws_security_group" "web-sg" {
  name        = "ansible-Web-SG"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "http port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg-name
  }
}

#create ec2 instances 

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 3.0"

  for_each = var.instance_configurations

  ##for_each = toset(["ansible-master", "target-node1", "target-node2"])

  name = each.value.name

  ami                    = each.value.ami != "" ? (each.value.ami == "debian" ? data.aws_ami.debian.id : each.value.ami == "ubuntu"   ? data.aws_ami.ubuntu.id : data.aws_ami.amazon-2.id) : data.aws_ami.amazon-2.id
  instance_type          = each.value.instance_type
  key_name               = aws_key_pair.ec2_key.key_name
  #monitoring             = true
  user_data              = each.value.user_data != "" ? file("${path.module}/${each.value.user_data}") : ""
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]

  tags = {
    Terraform   = "true"
    Environment = "${each.key}"
  }
}
# here we are using the Null resource to copy our ssh key into the master server.
resource "null_resource" "copy_ssh_key" {
  depends_on = [module.ec2_instance["master"]]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.ec2_key.private_key_pem
    host        = module.ec2_instance["master"].public_ip
  }

  provisioner "file" {
    source      = "${var.keypair-name}.pem"
    destination = "/home/ec2-user/${var.keypair-name}.pem"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/${var.keypair-name}.pem",
    ]
  }
}
