## 🏗️ Architecture Overview

This project implements a **High Availability (HA)** WordPress infrastructure on AWS, designed to be resilient and scalable.

### 🛡️ Core Components:
* **Application Load Balancer (ALB):** Acts as the single entry point, distributing incoming traffic across multiple instances and performing health checks to ensure reliability.
* **Auto Scaling Group (ASG):** Automatically adjusts the number of EC2 instances (Min: 2, Max: 5) based on CPU utilization, ensuring the application handles traffic spikes effectively.
* **Multi-AZ Deployment:** All resources are distributed across multiple Availability Zones to prevent downtime in case of a data center failure.
* **Shared Storage (Amazon EFS):** A managed NFS file system that allows multiple EC2 instances to share WordPress media files and configuration, ensuring data consistency during scaling events.
* **Network Isolation:** EC2 instances and the RDS database are hosted in **Private Subnets**, isolated from direct internet access. Only the ALB remains in the Public Subnet to handle external requests.

* ## 📊 Monitoring & Observability

To ensure the health and performance of the infrastructure, I implemented a robust monitoring solution using **Amazon CloudWatch**.

### 📈 CloudWatch Dashboard
A custom dashboard provides real-time visibility into the following metrics:
* **CPU Utilization:** Tracks the processing load across the Auto Scaling Group.
* **Database Connections:** Monitors the number of active sessions on the RDS instance.
* **Network In:** Visualizes incoming traffic patterns to identify potential connectivity issues.
* **Status Check Failed:** Alerts on hardware or software issues at the EC2 instance level.

### 🔔 Alarm Logic
I configured automated alarms to notify the team of critical events:
* **High CPU Usage (>80%):** Triggers a scaling event to maintain application responsiveness.
* **DB Connection Saturation (>80):** Alerts when the database is approaching its connection limit, preventing potential "Too many connections" errors for users.
* **Low Network Traffic:** Detects sudden drops in traffic, which may indicate DNS or Load Balancer misconfigurations.
* **Instance Health Failure:** Fires immediately if an EC2 instance fails its underlying hardware status checks.

## 🚀 How to Deploy

Follow these steps to spin up the infrastructure:

1. **Initialize Terraform:** Download the required providers and initialize the working directory.
   ```bash
   terraform init

  2. **Review the Plan: Preview the changes Terraform will make to your AWS account.
  terraform plan
  3. **Apply the Configuration: Deploy the resources. (Confirm with yes when prompted).
  terraform apply

  ### 🧜‍♂️ Final Step: The Mermaid Diagram

```markdown
## 🗺️ Infrastructure Map

```mermaid
graph TD
    User((External User)) --> R53[Route 53]
    R53 --> ALB[Application Load Balancer]
    
    subgraph VPC [AWS Managed VPC]
        subgraph Public_Subnets [Public Tier]
            ALB
        end
        
        subgraph Private_Subnets [Private Tier]
            ASG[Auto Scaling Group]
            ASG --> EC2_1[WordPress Instance A]
            ASG --> EC2_2[WordPress Instance B]
            
            EC2_1 & EC2_2 --> RDS[(RDS MySQL Multi-AZ)]
            EC2_1 & EC2_2 --> EFS[(Shared EFS Storage)]
        end
    end
    
    ASG -.-> CW[CloudWatch Monitoring]   
