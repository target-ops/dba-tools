# Resources Provisioned and Their Purposes

This Terraform configuration provisions a set of AWS resources with a focus on best practices. Aimed at creating a robust, easy to maintain and scalable infrastructure. Below is a detailed list of all the resources provisioned and their specific purposes:

## AWS RDS Aurora

- **Aurora DB Clusters (`module "rds_aurora_clusters"`)**: Provisions Aurora DB clusters for each database defined in `local.dbs`. These clusters are configured with various parameters such as engine type, version, instance size, and storage settings. They are designed for high availability and performance, supporting applications that require a relational database.

## AWS CloudWatch

- **Metric Alarms**: Creates CloudWatch metric alarms for monitoring CPU utilization and database connections for each Aurora DB instance. These alarms trigger the Lambda function when certain thresholds are exceeded, ensuring proactive monitoring and response to potential issues.

## AWS Lambda

- **Lambda Function (`module "lambda_function"`)**: Provisions a Lambda function named `CW_alarm_handler` designed to handle CloudWatch alarms. This function is 
triggered by CloudWatch alarms and can perform various actions, such as sending notifications to a Slack channel. The function runs on Python 3.12 runtime and 
its code is located in the `lambda_handler` directory.

## AWS Secrets Manager

- **Secret (`resource "aws_secretsmanager_secret" "webhook"`)**: Creates a secret in AWS Secrets Manager named `alarms-slack-webhook`. This secret stores the 
Slack webhook URL used by the Lambda function to send notifications.

- **Secret Version (`resource "aws_secretsmanager_secret_version" "version"`)**: Manages the version of the Slack webhook URL secret, allowing updates without 
triggering unnecessary changes or redeployments.

## AWS CloudWatch Logs

- **Log Group (`logging_log_group` in `module "lambda_function"`)**: Associates a CloudWatch Logs log group with the Lambda function for logging its execution and output. This aids in debugging and monitoring the function's performance and issues.

## AWS IAM

- **Lambda Permission (`resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda"`)**: Grants CloudWatch the permission to invoke the Lambda function. This is necessary for the function to be triggered by CloudWatch alarms.


## Prerequisites

Before using this module, ensure you have the following:

- Terraform version >= 1.0.0 installed on your machine.
- An AWS account setup and ready
- AWS S3 bucket for Terraform state storage
- AWS credentials for user with permissions policy allowing provisioning of the above resources and the above S3 bucket writing.
- AWS VPC
- Webhook from Slack workflow "RDS Alarms" for RDS monitoring alarms

## Usage

To use this module, follow these steps:
# Configuring AWS Credentials for Terraform

To securely manage AWS resources with Terraform, you need to authenticate using AWS credentials. There are three primary methods to configure these credentials: 
You can set your AWS credentials as environment variables on your system, an AWS creds file or using SSO. The method using the file is using ~/.aws/credentials is straightforward and simple but less secure than using environment vars or SSO.

## Using Environment Variables

1. **Export AWS Credentials**

   For best security use your preconfigured AWS CLI SSO. If you chose using simple creds open your terminal and run the following commands, replacing `<YOUR_AWS_ACCESS_KEY_ID>` and `<YOUR_AWS_SECRET_ACCESS_KEY>` with your actual AWS User credentials.

   ```sh
   export AWS_ACCESS_KEY_ID="<YOUR_AWS_ACCESS_KEY_ID>"
   export AWS_SECRET_ACCESS_KEY="<YOUR_AWS_SECRET_ACCESS_KEY>"

2. **Configurable Terraform Customization**

   Utilize the modules adaptability by tailoring your Terraform configurations to your needs. Use `locals.tf` and `default.tfvars` files to fine-tune a myriad of parameters, including engine types, versions, instance sizes, and storage options. This customization capability empowers you to meticulously align your infrastructure with your specific operational needs and performance criteria, ensuring an optimized deployment. 

3. **Deployment**

   Initialize the Terraform environment to prepare for module execution. This step will download the necessary providers and modules.
   
   ```sh
   terraform init \
     -backend-config="bucket=<YOUR_S3_BUCKET_NAME>" \
     -backend-config="key=<YOUR_STATE_FILE_NAME>.tfstate" \
     -backend-config="region=<YOUR_AWS_REGION>"
   
   # utilizing default.tfvars file, passing slack webhook as its secret
   terraform plan -var=slack_webhook="https://hooks.slack.com/XXXXXX"

   terraform apply -var=slack_webhook="https://hooks.slack.com/XXXXXX"
