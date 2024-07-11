#for the istance configurations, we can use any of the values "amazon,debian,ubuntu" so as to configure our nodes 
# to use amazon linux, ubuntu or debian.
instance_configurations = {
  "master" = {
    instance_type = "t3.micro"
    name          = "master-instance"
    user_data     = "install.sh"
    ami           = "amazon"
  },
  "node1" = {
    instance_type = "t3.micro"
    name          = "node1-instance"
    user_data     = ""
    ami           = "amazon"
  },
  "node2" = {
    instance_type = "t4g.micro"
    name          = "node2-instance"
    user_data     = ""
    ami           = "ubuntu"
  }
}


region = "us-east-1"

keypair-name= "ansible-key"
