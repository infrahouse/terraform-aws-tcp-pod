# Example: SSH Jumphost

Deploys an SSH jumphost behind an internet-facing Network Load Balancer:

- A Network Load Balancer listening on TCP port 22
- An Auto Scaling Group of Ubuntu instances in the backend subnets
- A Route53 A record `jumphost.<your zone>` pointing at the NLB
- A generated SSH key pair (the private key ends up in the Terraform state —
  use your own key pair for anything beyond a demo)

## Usage

```bash
terraform init
terraform apply \
  -var region=us-west-2 \
  -var dns_zone=example.com \
  -var 'lb_subnet_ids=["subnet-aaa", "subnet-bbb"]' \
  -var 'backend_subnet_ids=["subnet-ccc", "subnet-ddd"]'
```

`lb_subnet_ids` must be public subnets (with `map_public_ip_on_launch = true`) for the
NLB to be internet-facing; `backend_subnet_ids` are typically private subnets.

Once the apply completes, connect through the load balancer:

```bash
terraform output -raw ssh_private_key > /tmp/jumphost.pem && chmod 600 /tmp/jumphost.pem
ssh -i /tmp/jumphost.pem ubuntu@jumphost.<your zone>
```

## Cleanup

```bash
terraform destroy
```
