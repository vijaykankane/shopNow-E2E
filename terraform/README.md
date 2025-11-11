# terraform-bartman
terraform-bartman
# Terraform AWS Starter

Run:
  terraform init
  terraform plan -var-file=dev.tfvars
  terraform apply -var-file=dev.tfvars

Teardown:
  terraform destroy -var-file=dev.tfvars