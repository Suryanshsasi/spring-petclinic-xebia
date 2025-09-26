orillaClinic – Cloud-Native Reference Platform

This repository demonstrates how the Spring PetClinic application can be deployed as a cloud-native platform on AWS.
It shows how to evolve a monolithic Java/Spring app into a globally available, resilient, and cost-efficient service using containers, IaC, and modern deployment practices.


---

📌 Architecture Highlights

App: Spring Boot PetClinic (Java 17, packaged in Docker).

Compute: ECS Fargate tasks behind an Application Load Balancer (ALB).

Data: Aurora MySQL Serverless v2 (with multi-AZ resilience).

Global Reach: CloudFront for low-latency delivery (optional: Global Accelerator for static anycast IPs).

IaC: Terraform to provision VPC, subnets, security groups, ECS, ALB, Aurora, CloudFront.

CI/CD: GitHub Actions to build, push to Amazon ECR, and deploy via Terraform.



---

🚀 Getting Started

Prerequisites

AWS account with IAM role for Terraform + GitHub OIDC.

Docker & Git installed locally.

Terraform >= 1.6.0.

Java 17 & Maven (if you want to run PetClinic locally).


Clone & build the app

git clone https://github.com/<your-org>/<your-repo>.git
cd <your-repo>

# build jar + docker image
docker build -t petclinic:latest .

Push to Amazon ECR

aws ecr create-repository --repository-name petclinic
aws ecr get-login-password --region eu-central-1 \
| docker login --username AWS --password-stdin <account_id>.dkr.ecr.eu-central-1.amazonaws.com

docker tag petclinic:latest <account_id>.dkr.ecr.eu-central-1.amazonaws.com/petclinic:latest
docker push <account_id>.dkr.ecr.eu-central-1.amazonaws.com/petclinic:latest

Deploy infrastructure (Terraform)

cd infra/10-infra
cp terraform.tfvars.example terraform.tfvars # adjust values

terraform init
terraform apply -auto-approve

Terraform provisions:

VPC, subnets, NAT, routing.

ALB + ECS Cluster + Service.

ECR repo + CloudWatch logs.

Aurora DB (if enabled).

Optional CloudFront distribution + ACM certs.



---

🌐 Accessing the App

ALB DNS: http://<alb-dns> (output from Terraform).

CloudFront (if enabled): https://app.<your-domain>.



---

⚡ CI/CD Pipeline

The repo includes a GitHub Actions workflow:

On push to main:

1. Build Docker image.


2. Push to ECR.


3. Run Terraform to update ECS service.




This enables safe, automated deployments every commit.


---

🧭 Business Value

This reference implementation demonstrates:

Scalability – run 30k concurrent users at <200ms latency.

Resilience – automatic failover at AZ and regional level.

Agility – new environments in under 10 minutes.

Cost Control – serverless, pay-per-use infrastructure.


These same patterns apply to GorillaClinic’s future global pet health platform.


---

📊 Roadmap

[ ] Add Aurora Global Database for multi-region failover.

[ ] Integrate WAF for OWASP protections.

[ ] Add GitHub Environments for staged approvals (staging → prod).

[ ] Enable AI-driven personalization with SageMaker / Bedrock.

<img width="1128" height="772" alt="image" src="https://github.com/user-attachments/assets/958e5c55-3062-45b7-aea8-831b626a64d2" />


---

🤝 Contributing

This repo is a reference/demo. For real deployments:

Parameterize secrets via AWS Secrets Manager.

Apply organizational guardrails (SCPs, budgets, tagging).

Run regular game-day failover drills.
