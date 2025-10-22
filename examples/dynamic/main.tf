module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

  suffix = ["demo", "dynamic"]
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

module "networks" {
  source   = "cloudnationhq/vnet/azure"
  version  = "~> 9.0"
  for_each = local.vnet

  naming = local.naming
  vnet   = each.value
}

data "azurerm_subscription" "current" {}

module "virtual_network_manager" {
  source = "../.."

  depends_on = [module.networks]

  config = {
    name                = module.naming.virtual_network_manager.name_unique
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location
    scope_accesses      = ["Connectivity"]
    subscription_ids    = [data.azurerm_subscription.current.id]

    network_groups = {
      dynamic_networks = {
        name        = "dynamic-networks"
        description = "Network group with dynamic membership using Azure Policy"
      }
    }
  }
}
