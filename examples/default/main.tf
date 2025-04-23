module "ckavmenv" {
  source = "../../"
  production = "Dev"
# Setting environment variables for Terraform
subscription_id = ""
client_id       = ""
client_secret   = ""
tenant_id       = ""

# Not needed for public, required for usgovernment, german, china
environment = "china"
}
