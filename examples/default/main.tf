module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

  suffix = ["demo", "default"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

data "azurerm_subscription" "current" {}

module "virtual_network_manager" {
  source  = "cloudnationhq/vnm/azure"
  version = "~> 1.0"

  config = {
    name                = module.naming.virtual_network_manager.name_unique
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location
    scope_accesses      = ["Connectivity"]
    subscription_ids    = [data.azurerm_subscription.current.id]
  }
}
