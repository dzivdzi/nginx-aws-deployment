# Deployment Instructions for NGINX on AWS with Terraform & Ansible

## Overview
This guide helps you set up a secure NGINX deployment on AWS using Terraform and Ansible, including generating a self-signed certificate, importing SSH keys, and configuring your environment.

---

## Prerequisites
- AWS CLI configured with permissions to create resources.
- Terraform installed.
- OpenSSL installed.
- Ansible installed on the control node (bastion).
- SSH client.

---

## Step 1: Rename example tfvars file
mv terraform.tfvars.example terraform.tfvars

Update **only two lines** in `terraform.tfvars`:
- `certificate_arn` – will be set after importing the cert.
- `key_name` – will be set after generating/importing the SSH key.

---

## Step 2: Generate a Self-Signed Certificate & Import to AWS ACM
Run this command to generate a self-signed certificate:

openssl req -x509 -nodes -days 365 -newkey rsa:2048
-keyout nginx-selfsigned.key
-out nginx-selfsigned.crt
-subj "/C=US/ST=State/L=City/O=Organization/CN=yourdomain.com"


Next, import it into AWS ACM:

aws acm import-certificate
--certificate fileb://nginx-selfsigned.crt
--private-key fileb://nginx-selfsigned.key
--region us-east-1


AWS CLI will output the **Certificate ARN**, copy this into your `terraform.tfvars` as:

certificate_arn = "arn:aws:acm:us-east-1:your_account_id:certificate/your_certificate_id"


---

## Step 3: Generate an SSH Key Pair
Run:

ssh-keygen -t rsa -b 2048 -f ~/.ssh/your-key-name


Replace `<your-key-name>` with a meaningful name, e.g., `test-key`.  
This generates `~/.ssh/<your-key-name>` (private) and `~/.ssh/<your-key-name>.pub` (public).

### Import your public key into AWS:
aws ec2 import-key-pair
--key-name <your-key-name>
--public-key-material fileb://~/.ssh/<your-key-name>.pub
--region us-east-1


---

## Step 4: Update `terraform.tfvars`
Set your variables:

key_name = "<your-key-name>" # e.g., test-key2
certificate_arn = "<your-arn from above>"


---

## Step 5: Deploy Infrastructure
cd terraform
terraform init
terraform plan
terraform apply


---

## Step 6: Transfer SSH Key to Bastion
Copy your private SSH key to the bastion:

scp -i ~/.ssh/<your-key-name> ~/.ssh/<your-key-name> ubuntu@<BASTION_IP>:~/.ssh/


On the bastion, set proper permissions:

ssh -i ~/.ssh/<your-key-name> ubuntu@<BASTION_IP>
chmod 600 ~/.ssh/<your-key-name>


---

## Step 7: Configure Ansible on Bastion
Download your repo:

scp -i ~/.ssh/<your-key-name> -r ~/projects/nginx-aws-deployment/ansible ubuntu@<BASTION_IP>:~/


Login:
ssh -i ~/.ssh/<your-key-name> ubuntu@<BASTION_IP>


Check your SSH private key path in `inventory.ini`, e.g.:

[nginx]
<instance_private_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/<your-key-name>


Run your playbook (make sure you are inside the ansible folder if you want to run it as below, otherwise you need to provide the full path):
ansible-playbook -i inventory.ini site.yml


---

## Step 8: Test and Access Your Deployment
Get your ALB name:

aws elbv2 describe-load-balancers --query 'LoadBalancers[*].{Name:LoadBalancerName,DNS:DNSName}' --output table


Test access:

curl -k https://<alb-dns>/phrase

> Note: Since it's a self-signed certificate, you need `-k` to skip verification.

---

## Note:
- Replace all placeholder values (`<your-key-name>`, `<your-arn>`, `<BASTION_IP>`, `<instance_private_IP>`, `<alb-dns>`) with your actual values.
- Keep your private key (`~/.ssh/<your-key-name>`) secure.

