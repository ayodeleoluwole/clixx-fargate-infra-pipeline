# 🏗️ CliXX Fargate Infra


## Overview

This project provisions the platform infrastructure for running the CliXX Retail application on AWS ECS Fargate. This pipeline provisions all foundational AWS resources, peers the Jenkins VPC with the app VPC because they belong in different VPCs, restores the RDS database from snapshot via Ansible, and and create every other infrastructures needed to deploy the application.

---

## Prerequisites

- Jenkins with the following plugins: Slack Notification, Credentials Binding
- Terraform >= 0.12 installed on the Jenkins agent (`terraform-14` tool configured in Jenkins)
- Python 3 and pip available on the Jenkins agent
- AWS CLI configured on the Jenkins agent with Inspector2 permissions
- An active AWS account with AWS Inspector2 enabled
- An existing RDS snapshot named `clixx-retaildb`
- Slack workspace and channel configured for notifications
- Jenkins credentials store configured with: `DB_USER_NAME`, `DB_PASSWORD`, `DB_NAME`, `RDS_ENDPOINT`

---

## Pipeline Stages

| Stage | Description |
|---|---|
| **Initial Stage** | Manual approval gate — pipeline waits for confirmation before proceeding |
| **Terraform Init** | Initialises Terraform with remote S3 backend |
| **Terraform Plan** | Generates and saves an execution plan |
| **Deploy Infrastructure** | Provisions all AWS resources via `terraform apply` |
| **Configure VPC Peering Route** | Adds return route to Jenkins VPC route table to enable RDS access from Jenkins |
| **Restore CliXX Database** | Runs Ansible playbook to restore RDS instance from snapshot |
| **Wait For RDS** | Polls RDS until the instance is available and accepting connections |
| **Configure RDS Database** | Updates WordPress site URL in the database using Jenkins credentials |
| **Wait for Inspector Scan** | Waits 120 seconds for AWS Inspector2 to complete vulnerability scanning |
| **Build Vulnerability Report** | Fetches Inspector2 findings and outputs a severity-ranked report to `findings.txt` |

---

## Infrastructure

| Resource | Description |
|---|---|
| **VPC** | Custom VPC (`10.0.0.0/16`) with 2 public and 2 private subnets across AZs |
| **VPC Peering** | Peers app VPC with Jenkins VPC — enables Jenkins to reach RDS directly |
| **Internet Gateway** | Routes inbound traffic to public subnets |
| **NAT Gateways** | One per AZ — allows private subnet resources to reach the internet |
| **ALB** | Internet-facing Application Load Balancer with IP-based target group |
| **ECR** | Private container registry with image scanning on push |
| **ECS Cluster** | Fargate cluster with Container Insights enabled |
| **ECS Service** | 2 replica Fargate service behind the ALB |
| **Task Definition** | Fargate task (256 CPU / 512 MB) with CloudWatch logging |
| **RDS Subnet Group** | Subnet group for RDS placement in private subnets |
| **IAM** | ECS task execution role with `AmazonECSTaskExecutionRolePolicy` |
| **CloudWatch** | Log group `/ecs/clixx-retail` with 7-day retention |
| **Security Groups** | Layered — ALB → ECS → RDS, plus Jenkins VPC access to RDS |

---

## Security Architecture

```
Internet
    │
   ALB (port 80/443)
    │
   ECS Fargate (port 80 from ALB only)
    │
   RDS MySQL (port 3306 from ECS only)
    │
   RDS MySQL (port 3306 from Jenkins VPC via peering)
```

---

## Security Scanning

AWS Inspector2 is integrated directly into the pipeline. After infrastructure is deployed and the database is configured, the pipeline:

1. Waits 120 seconds for Inspector2 to complete its scan
2. Queries Inspector2 for all findings filtered by severity, title, and resource
3. Outputs a formatted findings table to `findings.txt` in the workspace
4. Sends a Slack notification confirming the report is complete

This ensures every infrastructure deployment is followed by an automated vulnerability assessment before the environment is handed over.

---

## Ansible Playbooks

**`deploy_db.yml`** — Restores the RDS MySQL instance from the `clixx-retaildb` snapshot. Accepts `security_group_id` and `db_subnet_group` as runtime variables sourced from Terraform outputs.

**`delete_db.yml`** — Removes the RDS instance without a final snapshot during teardown.

Both playbooks run inside a Python virtual environment provisioned on the Jenkins agent at runtime.

---

## Usage

**Via Jenkins** — point your Jenkins job at this repo. The pipeline handles everything end to end.


---

## Project Structure

```
clixx-fargate-infra/
├── instances/
│   ├── vpc.tf                  # VPC, subnets, IGW, NAT gateways, VPC peering
│   ├── security_group.tf       # ALB, ECS, and RDS security groups
│   ├── ALB.tf                  # Load balancer, target group, and listener
│   ├── ECR.tf                  # ECR repository with image scanning
│   ├── ECS_Cluster.tf          # ECS Fargate cluster and capacity providers
│   ├── ECS_Service.tf          # ECS service with ALB integration
│   ├── Task_Definition.tf      # Fargate task definition and CloudWatch logs
│   ├── iam.tf                  # ECS task execution role
│   ├── rds.tf                  # RDS subnet group
│   ├── data.tf                 # Data sources — AZs, Jenkins VPC
│   ├── backend.tf              # S3 remote state backend
│   ├── ouput.tf                # Resource outputs
│   ├── vars.tf                 # Input variables
│   └── versions.tf             # Terraform version constraint
├── deploy_db_ansible/
│   ├── deploy_db.yml           # Restore RDS from snapshot
│   └── delete_db.yml           # Delete RDS instance
├── Jenkinsfile                 # Jenkins pipeline definition
└── README.md
```

---

## Remote State

```
Bucket : mystatefile-clixxretail
Key    : base-infrastructure/terraform.tfstate
Region : us-east-2
```
