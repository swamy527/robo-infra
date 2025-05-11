module "roboshop" {
  source          = "git::https://github.com/swamy527/vpc-module.git?ref=main"
  project_name    = var.project_name
  environment     = var.environment
  public_subnet   = var.public_subnet
  private_subnet  = var.private_subnet
  database_subnet = var.database_subnet
}
