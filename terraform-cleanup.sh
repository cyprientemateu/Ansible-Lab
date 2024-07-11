#!/bin/bash

# Delete terraform on current directories and files
# this is done just for the testing purpose.
find . -type d -name '.terraform' -exec rm -rf {} +
find . -type f -name '.terraform.tfstate' -exec rm -f {} +
find . -type f -name '.terraform.lock.hcl' -exec rm -f {} +
find . -type f -name 'terraform.tfstate' -exec rm -f {} +
find . -type f -name 'terraform.tfstate.backup' -exec rm -f {} +
find . -type f -name '.terraform.tfstate.lock.info' -exec rm -f {} +

# find . -type f -name 'terraform.tfstate' -exec rm -f {} +
# find . -type f -name 'terraform.tfstate.backup' -exec rm -f {} +

# find "/home/cypri/OneDrive/Desktop" -type f -name 'terraform.tfstate' -exec rm -f {} \;
# find "/home/cypri/OneDrive/Desktop" -type f -name 'terraform.tfstate.backup' -exec rm -f {} \;

# Delete terragrunt directories and files
find . -type d -name '.terragrunt' -exec rm -rf {} +
find . -type d -name '.terragrunt-cache' -exec rm -rf {} +

# find "/home/cypri/OneDrive/Desktop" -type d -name '.terragrunt' -exec rm -rf {} \;
# find "/home/cypri/OneDrive/Desktop" -type d -name '.terragrunt-cache' -exec rm -rf {} \;

echo "Cleanup complete."
