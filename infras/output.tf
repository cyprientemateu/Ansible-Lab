output "ssh_commands" {
  value = {
    for instance_name, instance_config in var.instance_configurations :
    instance_name => join("", ["ssh -i ${var.keypair-name}.pem ", instance_config.ami != "" ? (instance_config.ami == "debian" ?  "admin" : instance_config.ami == "ubuntu" ?  "ubuntu" : "ec2-user"): "ec2-user", "@", module.ec2_instance[instance_name].public_dns])
  }
}

output "public-ips" {
  value = { for k, instance in module.ec2_instance : k => instance.public_ip

  }

}

output "private-ips" {
  value = { for k, instance in module.ec2_instance : k => instance.private_ip

  }

}