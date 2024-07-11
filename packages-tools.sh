#!/bin/bash

# Use Canonical, Ubuntu, 24.04 LTS, amd64 focal image build on 2023-10-25 to avoid any prompts

OS_NAME=$(grep -w NAME /etc/*release | awk -F'"' '{print $2}')
UBUNTU_VERSION=$(grep DISTRIB_RELEASE /etc/*release | awk -F"=" '{print $2}' | awk -F"." '{print $1}')

function yum_os {
  echo "This is $OS_NAME OS. Please wait ----------------------------------------------"
  sleep 5
  echo "This script can only run on Ubuntu for now. Support for Red Hat Enterprise Linux, CentOS Linux, and Amazon Linux has not been added yet."
  exit 1
}

function apt_os {
  echo "This is $OS_NAME 24 OS. Please wait ----------------------------------------------"
  sleep 5
  
  # List of packages to install
  packages=(
    curl 
    wget 
    vim 
    git 
    make 
    ansible 
    python3-pip 
    openssl 
    rsync 
    jq 
    postgresql-client 
    mariadb-client 
    mysql-client-8.0 
    mysql-client 
    unzip 
    tree 
    openjdk-11-jdk 
    default-jre 
    default-jdk 
    fontconfig 
    openjdk-17-jre 
    maven 
    nodejs 
    npm
  )
  
  # Update package index and upgrade installed packages
  sudo apt update -y
  sudo apt upgrade -y

  # Install packages
  for package in "${packages[@]}"; do
    echo "Installing $package. Please wait..."
    sleep 3
    sudo apt install -y "$package"
  done
  echo "Package installation completed."
}

function apt_software {
  # Install AWS CLI
  if command -v aws >/dev/null 2>&1; then
    echo "AWS CLI is already installed."
  else
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws
  fi

  # Install Terraform version 1.0.0
  TERRAFORM_VERSION="1.0.0"
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  terraform --version
  rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip

  # Install Grype
  GRYPE_VERSION="0.66.0"
  wget https://github.com/anchore/grype/releases/download/v${GRYPE_VERSION}/grype_${GRYPE_VERSION}_linux_amd64.tar.gz
  tar -xzf grype_${GRYPE_VERSION}_linux_amd64.tar.gz
  sudo chmod +x grype
  sudo mv grype /usr/local/bin/
  grype version

  # Install Gradle
  GRADLE_VERSION="4.10"
  sudo apt install openjdk-11-jdk -y
  wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
  unzip gradle-${GRADLE_VERSION}-bin.zip
  sudo mv gradle-${GRADLE_VERSION} /opt/
  /opt/gradle-${GRADLE_VERSION}/bin/gradle --version

  # Install kubectl
  sudo curl -o /usr/local/bin/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/kubectl
  sudo chmod +x /usr/local/bin/kubectl

  # Install kubectx and kubens
  sudo wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -O /usr/local/bin/kubectx
  sudo wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -O /usr/local/bin/kubens
  sudo chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens

  # Install Helm 3
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  sudo chmod 700 get_helm.sh
  sudo ./get_helm.sh
  sudo helm version

  # Install Docker Compose
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  docker-compose --version

  # Install Terragrunt
  TERRAGRUNT_VERSION="v0.38.0"
  sudo wget https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -O /usr/local/bin/terragrunt
  sudo chmod +x /usr/local/bin/terragrunt
  terragrunt --version

  # Install Packer
  PACKER_VERSION="1.7.4"
  sudo wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip -P /tmp
  sudo unzip /tmp/packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin
  sudo chmod +x /usr/local/bin/packer
  packer --version

  # Install Trivy
  sudo apt-get update -y
  sudo apt-get install wget apt-transport-https -y
  wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
  echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/trivy.list
  sudo apt-get update -y
  sudo apt-get install trivy -y

  # Install ArgoCD agent
  wget https://github.com/argoproj/argo-cd/releases/download/v2.8.5/argocd-linux-amd64
  chmod +x argocd-linux-amd64
  sudo mv argocd-linux-amd64 /usr/local/bin/argocd

  # Install Docker
  sudo apt-get remove docker docker-engine docker.io containerd runc -y
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg lsb-release -y
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io -y
  sudo systemctl start docker
  sudo systemctl enable docker

  # Set Docker permissions
  sudo chown root:docker /var/run/docker.sock
  sudo chmod 666 /var/run/docker.sock

  # Install Sonar Scanner CLI
  sonar_scanner_version="5.0.1.3006"
  wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${sonar_scanner_version}-linux.zip
  unzip sonar-scanner-cli-${sonar_scanner_version}-linux.zip
  sudo mv sonar-scanner-${sonar_scanner_version}-linux /var/opt/sonar-scanner
  sudo ln -s /var/opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/
  sonar-scanner -v
}

function user_setup {
  cat << EOF > /usr/users.txt
jenkins
ansible 
automation
EOF
  username=$(cat /usr/users.txt | tr '[A-Z]' '[a-z]')
  GROUP_NAME="tools"

  # Check and create group if not exists
  if grep -q "^$GROUP_NAME:" /etc/group; then
    echo "Group '$GROUP_NAME' already exists."
  else
    sudo groupadd "$GROUP_NAME"
    echo "Group '$GROUP_NAME' created."
  fi

  # Add group to sudoers if not already added
  if sudo grep -q "^%$GROUP_NAME" /etc/sudoers; then
    echo "Group '$GROUP_NAME' is already in sudoers."
  else
    echo "%$GROUP_NAME ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
    echo "Group '$GROUP_NAME' added to sudoers with NOPASSWD: ALL."
  fi

  # Allow automation tools to access Docker
  for i in $username; do
        if grep -q "^$i" /etc/sudoers; then
      echo "User '$i' is already in sudoers."
    else
      echo "$i ALL=(ALL) NOPASSWD: /usr/bin/docker" | sudo tee -a /etc/sudoers
      echo "User '$i' added to sudoers."
    fi

    # Create home directories and set permissions
    if [ ! -d "/home/$i" ]; then
      sudo mkdir -p /home/$i
    fi
    sudo chown -R $i:$i /home/$i

    # Add user to necessary groups
    sudo usermod -aG tools,docker $i

    # Set password for the user
    echo -e "$i\n$i" | sudo passwd $i > /dev/null 2>&1
    echo "User '$i' setup completed."
  done

  # Set vim as default text editor
  sudo update-alternatives --set editor /usr/bin/vim.basic
  sudo update-alternatives --set vi /usr/bin/vim.basic
}

function enable_password_authentication {
  # Check if password authentication is already enabled
  if grep -q "PasswordAuthentication yes" /etc/ssh/sshd_config; then
    echo "Password authentication is already enabled."
  else
    # Enable password authentication by modifying the SSH configuration file
    sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    echo "Password authentication has been enabled in /etc/ssh/sshd_config."

    # Restart the SSH service to apply changes
    sudo systemctl restart ssh
    echo "SSH service has been restarted."
  fi
}

function ssh_key {
  # Generate SSH keys for jenkins user
  sudo su - jenkins -c "ssh-keygen -t rsa -f /home/jenkins/.ssh/id_rsa -N '' || true"

  echo
  echo "Below is the private SSH key for Jenkins:"
  cat /home/jenkins/.ssh/id_rsa
  echo
  echo "Below is the public SSH key for Jenkins:"
  cat /home/jenkins/.ssh/id_rsa.pub
}

# Main script logic
if [[ $OS_NAME == "Red Hat Enterprise Linux" ]] || [[ $OS_NAME == "CentOS Linux" ]] || [[ $OS_NAME == "Amazon Linux" ]]; then
  yum_os
elif [[ $OS_NAME == "Ubuntu" ]] && [ $UBUNTU_VERSION -ge "24" ]; then
  apt_os
  apt_software
  user_setup
  enable_password_authentication
  ssh_key
else
  echo "This script is designed to run on Ubuntu 24.04. Please install Ubuntu 24.04 LTS to proceed."
  exit 1
fi
