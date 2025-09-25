# Infrastructure for eu-central-1

This folder contains Terraform and Docker configurations for deploying infrastructure in the AWS eu-central-1 region.

## Files

- Dockerfile: Contains instructions for building the Docker image.
- main.tf: Main Terraform configuration file.
- variables.tf: Variables used in Terraform configuration.
- outputs.tf: Outputs from Terraform.
- vpc.tf: VPC configuration.
- ecs.tf: ECS cluster configuration.
- ecr.tf: ECR repository configuration.
- cloudwatch.tf: CloudWatch log group configuration.
- aurora.tf: Aurora DB cluster configuration.
- route53.tf: Route53 DNS configuration.
- cloudfront.tf: CloudFront distribution configuration.
- push-to-ecr.sh: Script to push Docker images to ECR.

## Deployment

1. Configure AWS CLI with your credentials.
2. Initialize Terraform: `terraform init`
3. Plan the deployment: `terraform plan`
4. Apply the deployment: `terraform apply`
