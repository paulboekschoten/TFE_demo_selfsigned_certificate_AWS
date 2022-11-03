# Terraform Enterprise installation with self-signed certificates on AWS  
This repository installs Terraform Enterprise (TFE) with self-signed certificates in AWS on a Ubuntu virtual machine.  

This terraform code creates
 - A key pair
 - A security group
 - An Ubuntu virtual machine (22.04)
   - Self-signed certificates
   - Replicated configuration
   - TFE settings json
   - Install latest TFE
   - TFE Admin account


# Prerequisites
 - An AWS account with default VPC and internet access.
 - A TFE license

# How to install TFE with self-signed certficates on AWS
- Clone this repository.  
```
git clone https://github.com/paulboekschoten/tfe_demo_selfsigned_certificate_aws.git
```

- Go to the directory 
```
cd tfe_demo_selfsigned_certificate_aws
```

- Rename `terraform.tfvars_example` to `terraform.tfvars`.  
```
mv terraform.tfvars_example terraform.tfvars
```
- Change the values in `terraform.tfvars` to your needs.  

- Save your TFE license in `config/license.rli`.  

 - Set your AWS credentials
```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_SESSION_TOKEN=
```

- Terraform initialize
```
terraform init
```
- Terraform plan
```
terraform plan
```

- Terraform apply
```
terraform apply
```

Terraform output should show 8 resources to be created.  
```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

private_ssh_key = <sensitive>
public_ip = "35.180.86.221"
replicated_dashboard = "https://35.180.86.221:8800"
tfe_login = "https://35.180.86.221"
```


- Go to the Replicated dashboard. (Can take 10 minutes to become available.)  
- Click on the open button to go to TFE of go to the `tfe_login` url.  


## Obtaining private ssh key
Writing private ssh key to a pem file from terraform output.
```
terraform output -raw private_ssh_key > ../tfe_demo_paul_ubuntu.pem
```

## SSH Login
After obtaining the private ssh key, you can ssh to the machine with the following command.  
```
ssh -i ../TFEDemoPaulUbuntu.pem ubuntu@<public_ip>
```

# TODO


# DONE
 - [x] Create manually
 - [x] Create a key pair
 - [x] Create a security group
 - [x] Create a security group rules
 - [x] Create an EC2 instance
 - [x] Create self-signed certificates
 - [x] Install TFE 
   - [x] Download TFE
   - [x] Create settings.json
   - [x] Create replicated.conf
   - [x] Copy license.rli
   - [x] Create admin user
 - [x] Documentation