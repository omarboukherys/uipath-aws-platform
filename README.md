# uipath-aws-platform

Infrastructure as code (Terraform) for running a UiPath automation platform on AWS:
network, unattended robots on Windows EC2, data layer for a self-hosted Orchestrator,
queue-driven robot scaling, security and operations.

Work in progress.

## Layout

```
bootstrap/          Remote state bucket (S3, versioned, encrypted, TLS only)
modules/network/    Three-tier VPC across 3 AZs
platform/           Root configuration (S3 backend with native locking)
```

## Network

| Tier    | Subnets (/24)  | Route to the internet       | Hosts                          |
|---------|----------------|-----------------------------|--------------------------------|
| public  | 10.20.0-2.0    | Internet Gateway            | Load balancer, NAT Gateway     |
| private | 10.20.10-12.0  | NAT Gateway (optional)      | Orchestrator nodes, robots     |
| data    | 10.20.20-22.0  | none                        | SQL Server, Redis              |

- Default security group stripped of all rules: every resource uses an explicit group.
- No public IP on launch, even in public subnets.
- S3 gateway endpoint (free) on the private and data route tables.
- VPC flow logs to CloudWatch Logs (7-day retention).

### Cost switches

| Variable                     | Default | Hourly cost (eu-west-3)                | Why it is off by default |
|------------------------------|---------|----------------------------------------|--------------------------|
| `enable_nat_gateway`         | false   | NAT Gateway + public IPv4              | Only needed while robots run |
| `enable_interface_endpoints` | false   | 3 SSM endpoints x 1 AZ                 | Interface endpoints are billed per AZ-hour |

Lab trade-off: a single NAT Gateway in one AZ. Production: one per AZ, one private route table per AZ.

## Usage

```bash
# once
cd bootstrap && terraform init && terraform apply

# platform
cd platform
cp backend.hcl.example backend.hcl   # set the account id
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
terraform destroy                    # end of every working session
```

## Region

eu-west-3 (Paris).
