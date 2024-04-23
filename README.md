unprocessed-images/ folder needs to be created before use.. 

For Cloudfront customise this https://github.com/this-santhoshss/static-site-terraform-aws/tree/main 


Terraform on Mac M1

brew install kreuzwerker/taps/m1-terraform-provider-helper
m1-terraform-provider-helper activate
m1-terraform-provider-helper install hashicorp/template -v v2.2.0


### Commands

terraform init
terraform validate
terraform plan -var-file=terraform-dev.tfvars -out=tfplan
terraform apply
terraform destroy -auto-approve
