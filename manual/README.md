# Manual installation of TFE demo with selfsigned certificates on AWS

Here it is described how to manually install Terraform Enterpise (TFE) with selfsigned certificates on AWS.  

Official installation documentation can be found [here](https://www.terraform.io/enterprise/install/interactive/installer).  

# Prerequisites
 - AWS account
 - TFE license


# How to

## key pair
To be able to login with ssh to your ec2 instance, you'll need a key pair.  
Go to `Key pairs` and click `Create key pair`.  

![](media/2022-10-21-10-36-04.png)  
Give it a useful name and click `Create key pair`.  

A pem file will be downloaded in the browser.  
Store this pem file in a secure location and change the permissions to only your user.  
On linux/mac:
```
chmod 0600 TFEDemoPaul.pem
```

## Security group
Allow certain ports to connect to your TFE instance.  
Go to `Security Groups` and click `Create security groups`.  

![](media/2022-10-21-11-32-58.png)  

![](media/2022-10-21-11-33-22.png)  

![](media/2022-10-21-11-33-39.png)  
Click `Create security groups`.  

## EC2 instance
Create an EC2 instance to install TFE on.  
Go to EC2 instances and click `Launch instances`.  

![](media/2022-10-21-10-42-02.png)  

![](media/2022-10-21-10-42-18.png)  

![](media/2022-10-21-10-46-27.png)  
Pick m5.xlarge  

![](media/2022-10-21-10-42-57.png)  
Select the key pair created in the previous step.  

![](media/2022-10-21-11-35-05.png)  
Select the existing security group created in the previous step.  

![](media/2022-10-21-10-54-20.png)  
Set the size of the disk to 100GB.  

Click `Launch instance'.  

You can login with the pem file and the public ip.  
```
ssh -i TFEDemoPaul.pem ubuntu@52.47.75.180
```

## Selfsigned certificates
Login with ssh to the EC2 instance.  

```
mkdir -p /tmp/certs
cd /tmp/certs
```

First start by creating your CA key:

```
openssl genrsa -out tfe_ca.key 2048
```

Next we need to create our CA certificate
Here you have to fill in information about your company, it does not really matter as you have to trust it yourself.

```
openssl req -new -x509 -days 1095 -key tfe_ca.key -out tfe_ca.crt -subj "/C=EX/ST=Example/L=Example/O=Example, Inc./OU=Example/CN=Example Root"
```

Next we have to create a certificate for that server we want to use SSL on

```
openssl genrsa -out tfe_server.key 2048
```

After that we need certificate request, it is here you have to fill in the domain name that you are going to use the certificate with:

```
openssl req -new -key tfe_server.key -out tfe_server.csr  -subj "/C=EX/ST=Example/L=Example/O=Example, Inc./OU=Example/CN=52.47.75.180"
```

Then lastly we can create our server certificate
```
openssl x509 -req -days 365 -in tfe_server.csr -CA tfe_ca.crt -CAkey tfe_ca.key -CAcreateserial -out tfe_server.crt
```


## TFE
Install
```
cd /tmp/
curl -o /tmp/install.sh https://install.terraform.io/ptfe/stable
chmod +x /tmp/install.sh
sudo /tmp/install.sh
```

```
Determining local address
The installer will use network interface 'ens5' (with IP address '172.31.36.235')
Determining service address
The installer will use service address '52.47.75.180' (discovered from EC2 metadata service)
The installer has automatically detected the service IP address of this machine as 52.47.75.180.
Do you want to:
[0] default: use 52.47.75.180
[1] enter new address
Enter desired number (0-1): 0
```
Use the external ip address.  

```
Does this machine require a proxy to access the Internet? (y/N) N
```

```
Operator installation successful

To continue the installation, visit the following URL in your browser:

  http://52.47.75.180:8800
```

![](media/2022-10-21-13-53-51.png)  
Click `Continue to Setup`.  

![](media/2022-10-21-13-54-24.png)  
Click `Advanced` and then `Proceed to 52.47.75.180 (unsafe)`.  

Configure `HTTPS for admin console`
![](media/2022-10-21-14-00-21.png)  

 - Hostname: 52.47.75.180 (the CN you used with the certificate)
 - Click: If your private key and cert are already on this server, click here.
 - Private Key Path: /tmp/certs/tfe_server.key
 - Certificate Path: /tmp/certs/tfe_server.crt

Click `Save & Continue`.

Again you will get message about an unsafe connection.  
Click `Advanced` and then `Proceed to 52.47.75.180 (unsafe)`.  

![](media/2022-10-24-11-28-18.png)  
Upload you license file.  

![](media/2022-10-24-11-29-49.png)  
Choose Online and continue.  

![](media/2022-10-24-11-43-00.png)  
Enter a password.  

![](media/2022-10-24-11-44-44.png)  
Preflight checks should be good.  

![](media/2022-10-24-11-53-46.png)  
Error that mounted disk path is not set.  

On the commandline via ssh  
```
sudo mkdir /tfe_data
```

Go to `Settings` and then `Mounted Disk Configuration`.  
Under `Mounted Disk Path` enter `/tfe_data`.  

An `Encryption Password` password is also needed.  
Go to `Encryption Password` and provide a password.  
Save.  

![](media/2022-10-24-12-02-23.png)  
Click `Restart Now`.  

After a few minutes you should see
![](media/2022-10-24-12-06-55.png)  

Click on `Open` below `Stop Now`.   

Again you will get message about an unsafe connection.  
Click `Advanced` and then `Proceed to 52.47.75.180 (unsafe)`.  

Create an admin user.  
![](media/2022-10-26-11-36-31.png)   
Click `Create an account`.  

Create an organisation.  
![](media/2022-10-26-11-38-07.png)  
Click `Create organization`

![](media/2022-10-26-11-39-48.png)  

You now have a working TFE and can create workspaces.  

