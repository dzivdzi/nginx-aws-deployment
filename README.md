# nginx-aws-deployment
rename terraform.tfvars.example terraform.tfvars
Only 2 lines need to be changed there: certificate_arn & key_name you will add these once you run the below:
Generate self signed cert and upload it:
run to generate cert: 
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx-selfsigned.key \
  -out nginx-selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=yourdomain.com"

run to import it:
aws acm import-certificate \
  --certificate fileb://nginx-selfsigned.crt \
  --private-key fileb://nginx-selfsigned.key \
  --region us-east-1

The command will output the ARN - use it to copy paste it into terraform.tfvars

run to generate key:
ssh-keygen -t rsa -b 2048 -f ~/.ssh/<key-name>

Take the key-name and copy paste it in terraform.tfvars

run to import key:
aws ec2 import-key-pair \
  --key-name <key-name> \
  --public-key-material fileb://~/.ssh/<key-name>.pub \
  --region us-east-1

cd terraform
terraform init
terraform plan
terraform apply

copy ur key to bastion:
scp -i ~/.ssh/<key-name> ~/.ssh/<key-name> ubuntu@BASTION_IP_TAKEN_FROM_TERRAFORM_OUTPUT:~/.ssh/<key-name>

edit your ansible inventory file that you downloaded with the output from terraform - you will se private_instance_IP's:
./ansible/inventory.ini
Also, you need to change the key-name there as well - below is the provided inventory file:
[nginx]
<instance_private_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/<key-name>
<instance_private_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/<key-name>
<instance_private_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/<key-name>

[all:vars]
ansible_python_interpreter=/usr/bin/python3


Copy the entire ansible folder to bastion:
scp -i ~/.ssh/<key-name> -r ~/projects/nginx-aws-deployment/ansible ubuntu@BASTION_IP:~/

log in bastion
ssh -i ~/.ssh/<key-name> ubuntu@BASTION_IP
give 600 permissions to the key:
chmod 600 ~/.ssh/<key-name>

cd ansible

PLEASE DOUBLE CHECK THAT YOU'VE GOT THE RIGHT VALUES IN THE INVENTORY FILE

ansible-playbook -i inventory.ini site.yml

After that's done, run the below to get your ALB's name:
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].{Name:LoadBalancerName,DNS:DNSName}' --output table

To test it:
curl -k https://<alb-name>/phrase

Please note that if you try to test it without -k (which explicitly tells it that it's OK to perform this unsecurely), it will tell you  that the cert is selfsigned.