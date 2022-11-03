#!/bin/bash

# wait for internet connectivity
while ! curl -ksfS --connect-timeout 5 https://icanhazip.com; do
    sleep 5
done

# get public ip
public_ip=$(curl -4 icanhazip.com)

# create directory to hold certs
mkdir -p /tmp/certs
cd /tmp/certs

# create self-signed certificates
openssl genrsa -out tfe_ca.key 2048
openssl req -new -x509 -days 1095 -key tfe_ca.key -out tfe_ca.crt -subj "/C=EX/ST=Example/L=Example/O=Example, Inc./OU=Example/CN=Example Root"
openssl genrsa -out tfe_server.key 2048
openssl req -new -key tfe_server.key -out tfe_server.csr  -subj "/C=EX/ST=Example/L=Example/O=Example, Inc./OU=Example/CN=$public_ip"
openssl x509 -req -days 365 -in tfe_server.csr -CA tfe_ca.crt -CAkey tfe_ca.key -CAcreateserial -out tfe_server.crt

# create a directory where TFE stores it's data
sudo mkdir /tfe_data

# create settings.json
cat >/etc/settings.json <<EOL
{
    "hostname": {
        "value": "$public_ip"
    },
    "disk_path": {
        "value": "/tfe_data"
    },
    "enc_password": {
        "value": "${enc_password}"
    }
}
EOL

# create replicated.conf
cat >/etc/replicated.conf <<EOL
{
    "DaemonAuthenticationType":     "password",
    "DaemonAuthenticationPassword": "${replicated_password}",
    "TlsBootstrapType":             "server-path",
    "TlsBootstrapHostname":         "$public_ip",
    "TlsBootstrapCert":             "/tmp/certs/tfe_server.crt",
    "TlsBootstrapKey":              "/tmp/certs/tfe_server.key",
    "BypassPreflightChecks":        true,
    "ImportSettingsFrom":           "/etc/settings.json",
    "LicenseFileLocation":          "/tmp/license.rli"
}
EOL

# download and install the latest tfe
cd /tmp/
curl -o install.sh https://install.terraform.io/ptfe/stable
sudo bash ./install.sh


# wait for TFE to become ready
while ! curl -ksfS --connect-timeout 5 https://$public_ip/_health_check; do
    sleep 5
done

# create request payload for admin account
cat >/tmp/payload_admin.json <<EOL
{
  "username": "${admin_username}",
  "email": "${admin_email}",
  "password": "${admin_password}"
}
EOL


# get replicated token to create admin account
initial_token=$(replicated admin --tty=0 retrieve-iact | tr -d '\r')


# api call to create admin account
curl -k \
  --header "Content-Type: application/json" \
  --request POST \
  --data @/tmp/payload_admin.json \
  https://$public_ip/admin/initial-admin-user?token=$initial_token

