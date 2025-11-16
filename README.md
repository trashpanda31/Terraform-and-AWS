# ☁️ Terraform & AWS Labs (IAC)

This repo is a small **Terraform on AWS** playground:  
a hands-on set of five labs to practice real Terraform workflows on AWS.  
You’ll go from a simple VPC with one EC2 instance, to Nginx and Docker on EC2,  
then to a two-tier setup with frontend, API and Postgres, connected through VPC, subnets, NAT and security groups.  
Everything is managed as code, with **remote state in S3 + DynamoDB** and **GitHub Actions CI/CD** keeping the labs in sync.

## 📁 Structure

- `bootstrap/` - creates S3 bucket + DynamoDB table for Terraform state  
- `labs/lab01…lab05/` - individual Terraform labs, growing in complexity  
- `.github/workflows/` - CI/CD for Terraform and for the workflows themselves  
- `.gitignore` - standard Terraform ignores

## ✨ Quick links

- **Labs:** [labs/](labs/) - all labs tab
- **Terraform CI/CD:** [.github/workflows](.github/workflows) - used CI/CD pipelines
- **Pull Requests:** [PR tab](../../pulls) - open and closed change requests.
- **CI/CD runs:** [Actions tab](../../actions) - `CI_for_Terraform` and `CD_for_Terraform_to_AWS` runs
- **Docker Hub:** [trashpanda31](https://hub.docker.com/u/trashpanda31) - used images

## 🔥 Labs details

### Lab 01 - VPC + EC2 for SSH
- **Focus:** minimal setup.  
- **Network (Terraform):** VPC `10.10.1.0/24`, public subnet with public IPs, IGW + route table `0.0.0.0/0`.  
- **EC2:** `aws_instance.vm` (Amazon Linux 2023), SG `ssh` (22/tcp), optional SSH key.  
- **State:** S3 bucket `devops-state-504508177008`, DynamoDB table `DevOps-lock`.


### Lab 02 - EC2 with Nginx and SSH Keys
- **Focus:** web server and SSH keys.  
- **Network:** VPC `10.20.0.0/16`, public subnet `10.20.0.0/24`, IGW, route `0.0.0.0/0 > IGW`.  
- **EC2 and access:** `aws_instance.web` (Amazon Linux 2023) + `aws_eip.web`, SG `web` (HTTP 80, HTTPS 443, SSH 22 with `ssh_cidr`).  
- **Keys and Nginx:** `tls_private_key` > `aws_key_pair` > `local_file` with the private key, `user_data.sh` installs and enables Nginx.  
- **State:** S3 key `labs/lab2-vpc-ec2/terraform.tfstate` + `DevOps-lock`.


### Lab 03 - EC2 with Docker Container from Registry
- **Focus:** running a Docker app on EC2 via `user_data`.  
- **Network and EC2:** VPC `10.40.0.0/16`, public subnet `10.40.0.0/24`, IGW, route `0.0.0.0/0`, EC2 `aws_instance.web` with EIP and SG `web` (HTTP 80).  
- **Docker:** `user_data.sh.tmpl` installs Docker, pulls `var.docker_image` (default `trashpanda31/lab03:latest`), maps `host_port` > `container_port` and performs an HTTP check.  
- **State:** S3 key `labs/lab3-min-ec2-docker/terraform.tfstate` + `DevOps-lock`.


### Lab 04 - Public Frontend, Private Backend in One VPC
- **Focus:** two-tier app with backend hidden behind NAT.  
- **Network:** VPC `10.42.0.0/16`, public subnet `10.42.1.0/24` (public IP), private subnet `10.42.2.0/24`, IGW, NAT Gateway, separate public/private route tables.  
- **EC2 and security:** backend `aws_instance.backend` in private subnet (no public IP), frontend `aws_instance.frontend` in public subnet with EIP; SG `frontend` (HTTP/SSH from the internet), SG `backend` (inbound only from frontend).  
- **Docker images:** backend via `usedata-backend.sh` (`var.back_image`, default `trashpanda31/lab04-src-server:latest`), frontend via `usedata-frontend.sh` (`var.front_image`, default `trashpanda31/lab04-src-client:latest`, `API_ORIGIN` pointing to backend private IP).  
- **State/outputs:** S3 key `lab04/terraform.tfstate` + `DevOps-lock`; outputs with `frontend_public_ip`, `backend_private_ip`, `frontend_url`.


### Lab 05 - Modular Stack: VPC + EC2 + Docker (Postgres + API + Frontend)
- **Focus:** modular "mini-prod" stack.  
- **Modules:**  
  - `vpc` - VPC, public/private subnets, IGW, NAT, routes.  
  - `security` - SG frontend (HTTP `frontend_port`) and backend (only traffic from frontend).  
  - `iam_ssm` - EC2 role + instance profile with `AmazonSSMManagedInstanceCore`.  
  - `ec2` - EC2 instances with EIP and `user_data_replace_on_change`.  
- **Instances:** backend in private subnet with no public IP; frontend in public subnet with EIP; both with SSM roles.  
- **Docker stack:** on backend, `user_data_backend` creates network `lab05`, runs `postgres:15-alpine` and `lab05-backend`; on frontend, `user_data_frontend` runs `lab05-frontend` behind Nginx, proxying `/api` to the private backend.  
- **State/outputs:** shared S3/DynamoDB backend; outputs with VPC/subnet IDs, instance IDs, IPs and final frontend URL.

## 🚀 How to run

#### 0. Configure AWS profile (one time per machine)

You need an AWS account and an IAM user with programmatic access and permissions for S3, DynamoDB, EC2, VPC, IAM, etc.  
Configure the AWS CLI profile that Terraform will use:

```bash
aws configure --profile DevOps
# AWS Access Key ID: <your key>
# AWS Secret Access Key: <your secret>
# Default region name: eu-north-1
# Default output format: json
````

#### 1. **Bootstrap remote state** (one time per account)

```bash
cd bootstrap
terraform init
terraform apply -var="aws_profile=DevOps" -var="prefix=DevOps"
```

#### 2. **Deploy a lab**

```bash
cd labs/lab03     # or lab01..lab05
terraform init
terraform apply
```

#### 3. **Destroy when done**

```bash
terraform destroy
```

## 📌 Summary

- **Gradual Terraform deep dive:** I go through five labs - from a single EC2 in a small VPC to a modular "mini-prod" with frontend, API, and Postgres.  
- **Real AWS networking:** I configure VPCs, public and private subnets, IGW and NAT, route tables, security groups, and Elastic IPs - the core building blocks of production-grade AWS infrastructure.  
- **Application delivery with Docker:** using EC2 `user_data` I install Docker, pull images from Docker Hub, wire up ports, and connect frontend, backend, and database into a working application.  
- **Safe remote state & automation:** in every lab I use S3 + DynamoDB for Terraform state storage and locking, and GitHub Actions makes plans and applies predictable and repeatable.  
- **Ops skills, not just theory:** SSH, SSM, health checks, Terraform outputs, and per-lab state keys give me hands-on practice in operating and debugging infrastructure changes.  
- **Reusable patterns:** in Lab 05 I've structured modules (VPC, security, IAM/SSM, EC2) as building blocks that I can reuse in future projects and evolve into more advanced IaC setups.

## 📸 AWS Screenshots

**EC2 instances for all labs**  
<img src="https://i.imgur.com/oP7rxC4.png" alt="EC2 instances for all labs" width="1000">

**VPCs created by the labs**  
<img src="https://i.imgur.com/a4uAdj0.png" alt="VPCs created by the labs" width="1000">

**Public and private subnets**  
<img src="https://i.imgur.com/0m9mjt2.png" alt="Public and private subnets" width="1000">

**DynamoDB table with Terraform state locks**  
<img src="https://i.imgur.com/2RAeTFR.png" alt="DynamoDB table with Terraform state locks" width="1000">

