# Mock app devops implementation 

## Implementation Description

1. Simple python api server that responds with a greeting, run in a Docker container. 
2. Deployed on AWS using Terraform. Deployment includes networking (VPC, Gateway, subnets over multiple AZs, rooting, load balancing)
3. Ansible playbook to initialize containerized Prometheus/Grafana monitoring. Also included a docker-compose.
4. Jenkinsfile with a simple CI/CD pipeline for Building/Testing/Deploying app and AWS configuration. 


## Setup Instructions

### AWS + Terraform Configuration

1. **Create new User:**
   - Establish a new group and assign the `AdministratorAccess` policy.
   - Create a new AWS user and add them to the aforementioned group.
   - Generate an access key pair for CLI use.

2. **AWS CLI Setup:**
   - Install AWS CLI
   ```sh
   # For Ubuntu
   sudo apt-get install awscli
   ```
   - Configure the AWS CLI with the generated access key. (Not needed for Jenkins agent)
   ```sh
   aws configure
   ```

3. **Install Terraform:**
   ```sh
   # For Ubuntu
   sudo apt-get install terraform
   ```

### CloudWatch Configuration

1. **Policy Creation:**
   - Create a custom policy for listing and reading CloudWatch metrics:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Action": [
             "cloudwatch:DescribeAlarms",
             "cloudwatch:ListMetrics",
             "cloudwatch:GetMetricStatistics",
             "cloudwatch:DescribeAlarmHistory",
             "cloudwatch:GetMetricData"
           ],
           "Resource": "*"
         }
       ]
     }
     ```

2. **New User for CloudWatch Exporter:**
   - Establish a new group with the above custom policy.
   - Create a new AWS user and add to above group.
   - Generate an access key pair for the Docker CloudWatch exporter.

### Ansible + Monitoring Setup

- Install Ansible.
- Create an Ansible Vault and add AWS keys:
  ```sh
  ansible-vault create group_vars/all/vault.yml
  ```
- Execute the playbook:
  ```sh
  ansible-playbook -i inventory --ask-vault-pass localsetup.yml
  ```

### Jenkins Configuration

- Prerequisites
    Assuming Jenkins is already set up.
    AWS Credential Plugin is installed.

- Credential Setup
    Configure credentials for Docker registry access.
    Configure AWS credentials for AWS CLI used by Terraform.

- Agent Setup
    Set up one Jenkins agent with Docker.
    Set up another agent with AWS CLI and Terraform.
