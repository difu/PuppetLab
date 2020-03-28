module "base-labels" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  namespace   = "difu"
  environment = var.environment
  delimiter   = "-"

  label_order = ["namespace", "environment"]

  tags = {
    "Environment" = var.environment
  }
}

module "puppet-master-labels" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  context     = module.base-labels.context
  name        = "puppetmaster"
  label_order = ["namespace", "environment", "name"]
}

module "puppet-client-webserver-labels" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  context     = module.base-labels.context
  name        = "webserver"
  label_order = ["namespace", "environment", "name"]
  tags = {
    "Role"    = "webserver"
  }
}