# TFE_demo_selfsigned_certificate_AWS
TFE demo version with selfsigned certificates on AWS

Writing private ssh key to a pem file from terraform output
```
terraform output -raw private_ssh_key > ../TFEDemoPaulUbuntu.pem
```

# TODO
 - [ ] Documentation

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