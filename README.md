# aws-ha-wordpress-terraform
Highly Available WordPress on AWS
This project automates the deployment of a scalable, fault-tolerant WordPress environment using Terraform.

Key Features:
High Availability: Spread across 2 Availability Zones.

Security: RDS password managed by AWS Secrets Manager with rotation.

Scalability: Auto Scaling Group (ASG) based on CPU load.

Storage: Amazon EFS for shared /var/www/ across all instances.

SSL/TLS: Automated certificate generation via ACM and termination at ALB.

Domain: Managed via Route53 (awspath.website).
