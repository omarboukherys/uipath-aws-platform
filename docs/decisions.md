# Architecture decisions

## 1. Orchestrator: UiPath Automation Cloud, robots on AWS (hybrid)
Orchestrator is consumed as SaaS. Only the execution layer (unattended robots) runs in the AWS account.
A self-hosted Orchestrator (multi-node behind a load balancer, SQL Server on RDS, Redis for the
High Availability Add-on) is a later, optional module.

## 2. Robots in private subnets, no inbound access
No public IP, no inbound security group rule, no RDP. Administration goes through SSM Session Manager.
Outbound: 443 (Automation Cloud, AWS APIs) and 80 (certificate revocation checks).

## 3. Credentials never in code or Terraform state
The machine template client ID and secret live in Secrets Manager, created with the AWS CLI.
Terraform only references the secret by name. The instance role can read this single secret.
The installer config file holding the secret is deleted at the end of the bootstrap, together with
the copy the UiPath Platform Installer keeps under `%TEMP%\UiPathConnected\`.

## 4. NAT Gateway vs interface endpoints
Robots must reach UiPath Automation Cloud, so they need internet egress anyway: a NAT Gateway.
SSM interface endpoints would only remove the SSM traffic from the NAT, and they are billed per
endpoint, per AZ and per hour (3 endpoints x 3 AZ cost more than one NAT Gateway).
Both are switched off outside working sessions. Lab: a single NAT Gateway (single point of failure).
Production: one NAT Gateway per AZ.

## 5. Background automations first
The robot account has no Windows credentials yet, so it runs background processes only.
Foreground (UI) automations need a local Windows user created at boot and its credentials in
Orchestrator (`.\username` syntax works across machines created from the same template).

## 6. Robot images are replaced, never patched in place
The Auto Scaling group uses the latest launch template version with an instance refresh: changing the
AMI or the bootstrap script rolls the robots. Lab setting: min healthy 0 %. Production: keep capacity
(min healthy 100 %, max healthy 200 %) and drain running jobs first.
