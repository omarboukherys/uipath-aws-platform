# uipath-aws-platform

Infrastructure as code (Terraform) for running a UiPath automation platform on AWS:
network, unattended robots on Windows EC2, data layer for a self-hosted Orchestrator,
queue-driven robot scaling, security and operations.

Work in progress.

## Layout

```
bootstrap/   Remote state bucket (S3, versioned, encrypted, native S3 locking)
```

## Region

eu-west-3 (Paris).
