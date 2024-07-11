# Ansible-Lab

# tcc-ci-cd-test

## Designing a ci-cd pipeline using Ansible, Jenkins ci or Gitlab ci.

### Design a pipeline for managing user accounts on all servers, consider the following structure:

Overview

The pipeline will use Ansible playbooks and a CI/CD tool (e.g., Jenkins CI, GitLab CI) to manage user accounts on Ubuntu and CentOS VMs. The pipeline will handle creating, deleting, disabling, and changing user shells. It will accept inputs in various forms and ensure all necessary operations are performed according to specified requirements.
 
Key Requirements

- Input Management:
  - Handle single user entry, list of user entries, array of user entries, and user lists uploaded as files.
  - Ensure SSH keys are provided for new users.
  - Include options for adding users to the sudoers file, with and without password prompts.

- User Management Operations:
  - Check if the user(s) exist.
  - Create home directories for new users.
  - Assign unique, randomly generated UIDs.
  - Assign users to specified groups, allowing for multiple group memberships.
  - Add full names as comments for users.
  - Add SSH keys from input.

- Compatibility:
  - Ensure the pipeline works with both Ubuntu and CentOS VMs.

Detailed Steps

1. Input Handling

   - Accept inputs as variables, files, or direct inputs.
   - Use Ansible Vault to securely manage sensitive data like SSH keys.

2. Pre-Operations Checks

   - Verify if the user already exists on the server.

3. User Creation

   - Create new users with unique UIDs.
   - Create home directories for new users.
   - Assign users to specified groups.
   - Add full names as comments.
   - Add SSH keys for new users.
   - Add users to the sudoers file if specified, with or without password prompts.

4. User Deletion

   - Remove users, including their home directories and SSH keys.

5. User Disabling

   - Lock user accounts without deleting home directories or removing SSH keys.

6. Change User Shell

   - Modify the user's shell if specified.

Pipeline Design

1. Infrastructure as Code (IaC)

   - Use Ansible playbooks to manage the infrastructure.
   - Store playbooks and inventory in a Git repository.

2. Ansible Playbook Structure

  Create tasks to handle the following:
   - Checking if users exist.
   - Creating new users.
   - Adding users to groups.
   - Adding SSH keys.
   - Managing sudoers file entries.
   - Deleting users.
   - Disabling users.
   - Changing user shells.

3. CI/CD Pipeline Configuration

  Define stages in the CI/CD tool:
   - Validation: Ensure the syntax and structure of the playbooks are correct.
   - Deployment: Execute the playbooks on the target servers.

Example GitLab CI or Jenkins CI Configuration

a-  Define stages: validate, deploy.
b-  Validate stage: Perform syntax checks on Ansible playbooks.
c-  Deploy stage: Execute Ansible playbooks to manage user accounts.

Example Inventory File

  - List target servers with their corresponding hostnames or IP addresses.

Example Users Input

  - Define user attributes such as name, full name, groups, shell, SSH key, sudoers file status, state (present, absent, disabled), and new shell if applicable.

## Summary

  - Ensure the pipeline can handle various input types and formats.
  - Securely manage sensitive data with Ansible Vault.
  - Implement robust error handling and logging.
  - Test the pipeline on both Ubuntu and CentOS VMs for compatibility.

By following this refined plan, you can create a comprehensive and robust pipeline for managing user accounts across multiple servers, ensuring all specified requirements are met.



# -------------------- IMPLIMENTATION ---------------------


##   1. Overview
The pipeline will leverage Ansible playbooks and GitLab CI or Jenkins CI to manage user accounts on both Ubuntu and CentOS VMs. It will handle user creation, deletion, disabling, and shell changes, ensuring compatibility across different Linux distributions.

##   2. Key Requirements

* Input Management
  
  * Handle various input formats: single user entries, lists of user entries, arrays of user entries, and user lists from files.
  * Ensure SSH keys are provided for new users.
  * Allow adding users to the sudoers file, with and without password prompts.
  
* User Management Operations
  
  * Verify if the user(s) already exist.
  * Create home directories for new users.
  * Assign unique, randomly generated UIDs.
  * Assign users to specified groups, supporting multiple group memberships.
  * Add full names as comments.
  * Add SSH keys from input.

* Compatibility
 
  * Ensure compatibility with both Ubuntu and CentOS VMs.

##  3. Detailed Steps
 
  Step 1: Input Handling

  Accept Inputs
  - Variables: Direct inputs from CI/CD variables.
  - Files: User lists uploaded as files.
  - Use Ansible Vault to securely manage sensitive data like SSH keys.

Example Input File (users.yml)

```yaml
users:
  - name: "jdoe"
    full_name: "John Doe"
    groups: ["developers", "sudo"]
    shell: "/bin/bash"
    ssh_key: "ssh-rsa AAAA..."
    sudoers: "yes"
    sudo_nopasswd: "yes"
    state: "present"
  - name: "asmith"
    full_name: "Alice Smith"
    groups: ["admins"]
    shell: "/bin/zsh"
    ssh_key: "ssh-rsa BBBB..."
    sudoers: "no"
    state: "present"
```

  Step 2: Pre-Operations Checks

  - Verify if the user already exists on the server.

  Step 3: User Creation
  - Create new users with unique UIDs.
  - Create home directories for new users.
  - Assign users to specified groups.
  - Add full names as comments.
  - Add SSH keys for new users.
  - Add users to the sudoers file if specified, with or without password prompts.

  Step 4: User Deletion
  
  - Remove users, including their home directories and SSH keys.

  Step 5: User Disabling
  
  - Lock user accounts without deleting home directories or removing SSH keys.

  Step 6: Change User Shell
  
  - Modify the user's shell if specified.

##  4. Pipeline Design

Infrastructure as Code (IaC)

 * Use Ansible playbooks to manage the infrastructure.
 * Store playbooks and inventory in a Git repository.

Ansible Playbook Structure

 - Main Playbook (manage-users.yml)

```yaml
---
- hosts: all
  become: yes
  vars_files:
    - "vault.yml"
  tasks:
    - name: Check if user exists
      getent:
        database: passwd
        key: "{{ item.name }}"
      register: user_exists
      with_items: "{{ users }}"
      ignore_errors: yes

    - name: Create users
      user:
        name: "{{ item.name }}"
        comment: "{{ item.full_name }}"
        uid: "{{ lookup('password', '/dev/null length=5 chars=digits') }}"
        groups: "{{ item.groups | join(',') }}"
        shell: "{{ item.shell }}"
        state: "{{ item.state }}"
        createhome: yes
      when: user_exists is failed
      with_items: "{{ users }}"

    - name: Add SSH keys
      authorized_key:
        user: "{{ item.name }}"
        key: "{{ item.ssh_key }}"
        state: present
      with_items: "{{ users }}"
      when: item.state == 'present'

    - name: Add to sudoers
      lineinfile:
        dest: /etc/sudoers
        state: present
        regexp: "^{{ item.name }}"
        line: "{{ item.name }} ALL=(ALL) NOPASSWD:ALL"
      with_items: "{{ users }}"
      when: item.sudoers == 'yes' and item.sudo_nopasswd == 'yes'

    - name: Add to sudoers with password
      lineinfile:
        dest: /etc/sudoers
        state: present
        regexp: "^{{ item.name }}"
        line: "{{ item.name }} ALL=(ALL) ALL"
      with_items: "{{ users }}"
      when: item.sudoers == 'yes' and item.sudo_nopasswd != 'yes'

    - name: Delete users
      user:
        name: "{{ item.name }}"
        state: absent
        remove: yes
      when: item.state == 'absent'
      with_items: "{{ users }}"

    - name: Disable users
      user:
        name: "{{ item.name }}"
        state: present
        password_lock: yes
      when: item.state == 'disabled'
      with_items: "{{ users }}"

    - name: Change user shell
      user:
        name: "{{ item.name }}"
        shell: "{{ item.new_shell }}"
      when: item.new_shell is defined
      with_items: "{{ users }}"
```

CI/CD Pipeline Configuration

 - GitLab CI Configuration (.gitlab-ci.yml)

```yaml
stages:
  - validate
  - deploy

validate:
  stage: validate
  script:
    - ansible-playbook --syntax-check manage_users.yml

deploy:
  stage: deploy
  script:
    - ansible-playbook -i inventory.yml manage_users.yml --extra-vars "users=@users.yml"
```

Jenkins Pipeline Configuration
 
 - Jenkinsfile

```groovy
pipeline {
    agent any

    environment {
        ANSIBLE_VAULT_PASSWORD = credentials('ansible-vault-password')
    }

    stages {
        stage('Validate') {
            steps {
                script {
                    // Perform syntax check on the Ansible playbook
                    sh 'ansible-playbook --syntax-check manage_users.yml'
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    // Execute the Ansible playbook to manage user accounts
                    sh '''
                        ansible-playbook -i inventory.yml manage_users.yml \
                        --extra-vars "@users.yml" \
                        --vault-password-file <(echo $ANSIBLE_VAULT_PASSWORD)
                    '''
                }
            }
        }
    }
    post {
        always {
            // Archive the results, logs, and any other important files
            archiveArtifacts artifacts: '**/logs/*.log', allowEmptyArchive: true
        }
    }
}
```

Setting Up Jenkins Credentials

1- Add Vault Password Credential:
   . Go to Jenkins dashboard.
   . Click on "Manage Jenkins" > "Manage Credentials".
   . Add a new credential of type "Secret text" with ID ansible-vault-password.
   . Enter the Ansible Vault password.

Example Inventory File (inventory.yml)

```yaml
[ubuntu]
ubuntu-server-1 ansible_host=192.168.1.10 ansible_user=ubuntu

[centos]
centos-server-1 ansible_host=192.168.1.20 ansible_user=centos
```

##  5. Summary

This refined plan ensures a comprehensive and robust pipeline for managing user accounts across multiple servers. The pipeline is designed to handle various input types and formats, securely manage sensitive data with Ansible Vault, and provide robust error handling and logging. Testing on both Ubuntu and CentOS VMs ensures compatibility and reliability.
