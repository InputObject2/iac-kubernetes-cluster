# IAC Kubernetes Cluster
The goal of this repo is to create a Kubernetes cluster from scratch using Terraform, Ansible, RKE and Xen Orchestra.

## Prerequisites
There are a few systems that are expected to be working for this code to run:
- Xen Orchestra (and a XCP-NG cluster)
- A cloud-init VM template
- A DNS server that allows dynamic updates
- A Certificate Aauthority that can allow terraform to sign the certificates for the cluster
    - this certificate and key should be located under `files/ca/ca.pem` and `files/ca/ca-key.pem`
- A working KRB5_CONF (since I'm using Secure Dynamic updates with GSSAPI on Windows DNS)
- Terraform and Ansible

## Setup
Export the following environment variables:
```bash
export KRB5_CONF=/path/to/kbr5.conf
export XOA_USER=...
export XOA_PASSWORD=...
export TF_VAR_dns_server="dns-server.domain.com."
export TF_VAR_dns_username=...
export TF_VAR_dns_password=...
export TF_VAR_dns_realm="DOMAIN.com"
```

## Usage
First, run the terraform to create:
- virtual machines, 
- cluster certificates, 
- dns records
- ansible inventory

```bash
terraform apply
```

This will give you an ansible inventory containing all the information to access the servers.

There will be 2 groups: `k8s-nodes` and `k8s-masters`
