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

openssl genrsa -out tfe_ca.key 2048
openssl req -new -x509 -days 1095 -key tfe_ca.key -out tfe_ca.crt -subj "/C=EX/ST=Example/L=Example/O=Example, Inc./OU=Example/CN=Example Root"
openssl genrsa -out tfe_server.key 2048
openssl req -new -key tfe_server.key -out tfe_server.csr  -subj "/C=EX/ST=Example/L=Example/O=Example, Inc./OU=Example/CN=$public_ip"
openssl x509 -req -days 365 -in tfe_server.csr -CA tfe_ca.crt -CAkey tfe_ca.key -CAcreateserial -out tfe_server.crt