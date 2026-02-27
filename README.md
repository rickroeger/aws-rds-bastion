# aws-rds-bastion

## Instroduction

- Simple app on terraform frontend EC2 and backend RDS postgres

## Usage

- Confirm de postgres version that you want.
```
aws rds describe-db-engine-versions --default-only --engine postgres --profile mvp
```

- Change the file terraform.tfvars as you need
```
#main configuration
region      = "us-east-2"
app         = "bastion-app"
environment = "prd"
profile     = "mvp"

#network configs
cidr                = "192.168.0.0/20"
azs                 = ["us-east-2a", "us-east-2b", "us-east-2c"]
vpc_private_subnets = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"]
vpc_public_subnets  = ["192.168.3.0/24", "192.168.4.0/24", "192.168.5.0/24"]
vpc_database_subnets  = ["192.168.6.0/24", "192.168.7.0/24", "192.168.8.0/24"]

#DB configs
db_name  = "app"
username = "appadmin"
```
- Exeute the terraform apply and init
```
terraform init
terraform apply
```

## Connect on database

- Describing RDS information
```
aws rds describe-db-instances --profile mvp --region us-east-2
```

- Describing EC2 instances
```
aws ec2 describe-instances --profile mvp --region us-east-2
```

- Describing Secrets
```
aws secretsmanager list-secrets --profile mvp --region us-east-2
```

- Get the secret from AWS Secrets manager

```
aws secretsmanager get-secret-value --secret-id 'arn:aws:secretsmanager:us-east-2:xxx:secret:rds!db-aba6fxxxx-d27a-481c-bf29-1a1e75365410-Pn8g4l' --query SecretString --output text | jq -r '.password'
```

- Connect on Database

Executing the PortForward on linux
```
aws ssm start-session --target i-01e0057d10b1cexxx --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"host":["postgres-bastion-app-prd.colb3fjivxxx.us-east-2.rds.amazonaws.com"],"portNumber":["5432"],"localPortNumber":["5432"]}' --profile mvp 
```

Executing the PortForward on Windows
```
aws ssm start-session ^
Mais?   --target i-01e0057d10b1cexxx ^
Mais?   --document-name AWS-StartPortForwardingSessionToRemoteHost ^
Mais?   --parameters "{\"host\":[\"postgres-bastion-app-prd.colb3fjivxxx.us-east-2.rds.amazonaws.com\"],\"portNumber\":[\"5432\"],\"localPortNumber\":[\"5432\"]}" ^
--profile mvp --region us-east-2
```

- Connect on Datase using the psql
```
psql -d app -U appadmin
```