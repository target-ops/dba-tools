# 🚀 Target-Ops: dba-tools

Welcome to **dba-tools**,


### MySQL 🐬
The `mysql` directory is your go-to place for MySQL-related automation:

- **backup**: A Dockerized solution for logical backup and restore at scale of MySQL databases. Utilizing:
  - `azcopy`
  - `mysql`
  - `mydumper`
  - `myloader`
  - `percona-toolkit`
  - `Docker`
  - `mysqlkit`
  
  - **mysqlkit.sh**: CLI toolkit for MySQL database backup and restore. The MySQL Toolkit 🚀 supports the following commands:
    - **backup**: Create backups of AWS RDS DB MySQL tables and upload them to a Blob Store.
    - **restore**: Restore MySQL tables from Blob Storage.
    - **test_script**: Test the script and display some diagnostic information.
    - **run_command**: Execute SQL commands or MySQL Client commands.
    - **restore_command**: Execute restore and run_command sequentially.

- ** 🌟 Replication Tools 🌟**
  Useful Dockerfile:
    - **Database Tools**: PostgreSQL, MySQL clients, and Percona Toolkit for   MySQL database management.
    - **Networking Tools**: `net-tools`, `iproute2`, `dnsutils`, `traceroute`,    `telnet`, `tcpdump`, `nmap`, etc., for network analysis.
    - **System Monitoring**: `htop`, `iftop`, `ncdu`, `psmisc` for monitoring     system resources.
    - **Miscellaneous Utilities**: `curl`, `wget`, `jq`, `less`, `unzip`,   `zip`,  `tar`, `sudo`, etc., for various tasks.


### AWS RDS 🗄️

  - ** Provision AWS Aurora Cluster
    # Terraform Configuration
  
    This Terraform configuration is designed to manage infrastructure on AWS. It includes both backend configuration and provider   setup   to ensure a smooth infrastructure as code experience.
  
    ## Backend Configuration
  
    The backend is configured to use Amazon S3 for storing Terraform state files. This ensures that the state is shared and locked,     preventing conflicts during concurrent operations. The configuration includes:
  
    - **Bucket**: The S3 bucket where the Terraform state files are stored. Replace `S3_BUCKET_NAME_HERE` with the actual bucket name.
    - **Encrypt**: Set to `true` to enable encryption at rest for the state files.
    - **Key**: The path within the bucket to the state file. Replace `S3_KEY_HERE` with the appropriate key.
    - **Region**: The AWS region where the S3 bucket is located. Replace `AWS_REGION_HERE` with the actual region.
  
    ## Provider Configuration
  
    The AWS provider is configured with a region and default tags. The region is sourced from a variable, allowing for flexible     deployment across different AWS regions. Default tags are applied to all resources managed by Terraform, including:
  
    - **Environment**: Specifies the environment (e.g., production, staging). This is sourced from a variable.
    - **Automation**: Indicates that the resource is managed by Terraform.
    - **Team**: Specifies the team responsible for the resource. This is also sourced from a variable.
  
    ## Requirements
  
    To use this configuration, you will need:
  
    - Terraform installed on your machine.
    - An AWS account and the AWS CLI configured with access credentials.
    - The specified AWS infra ready, AWS VPC network and TF state S3 bucket created and accessible.
  
    ## Usage
  
    1. Navigate to the Terraform folder.
    2. Update the `providers.tf` `aurora.tf` files with your specific values (state bucket name, key, region, etc.).
    3. Initialize Terraform to download the required providers and set up the backend by running `terraform init`.
    4. Apply the configuration with `terraform apply`.
  
    Ensure you review and understand the costs associated with the resources managed by this Terraform configuration in your AWS  account.
  
  - ** 🔄 replicate.sh 🔄

    This script (`replicate.sh`) automates the process of replicating a master RDS MySQL database to a    replica, ensuring data synchronization across database instances. 🗄️➡️🗄️


---

## 📦 Installation


## 🚀 Usage
See each individual tool's README

## 💡 Contributing
We welcome contributions from the community! Feel free to contribute to the repository and submit pull requests.

## Core required for ghpage
https://github.com/jrnewton/github-readme-to-html 
```
npx github-readme-to-html README.md
cp dist/index.html ./README.html && rm -rf ./dist/
```
