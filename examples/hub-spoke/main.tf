module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

  suffix = ["demo", "dev"]
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
  source  = "cloudnationhq/vnm/azure"
  version = "~> 1.0"

  config = {
    name                = module.naming.virtual_network_manager.name_unique
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location
    scope_accesses      = ["Connectivity"]
    subscription_ids    = [data.azurerm_subscription.current.id]

    network_groups = {
      all_networks = {
        name        = "all-networks-with-spokes"
        description = "Network group containing hub and all spoke networks"
      }
    }

    static_members = {
      hub_member = {
        network_group_key         = "all_networks"
        name                      = "hub-member"
        target_virtual_network_id = module.networks["hub"].vnet.id
      }
      spoke1_member = {
        network_group_key         = "all_networks"
        name                      = "spoke1-member"
        target_virtual_network_id = module.networks["spoke1"].vnet.id
      }
      spoke2_member = {
        network_group_key         = "all_networks"
        name                      = "spoke2-member"
        target_virtual_network_id = module.networks["spoke2"].vnet.id
      }
    }

    connectivity_configurations = {
      hub_spoke = {
        name                  = "hub-spoke-connectivity"
        description           = "Hub-and-spoke connectivity configuration"
        connectivity_topology = "HubAndSpoke"

        applies_to_groups = [{
          network_group_key   = "all_networks"
          group_connectivity  = "None"
          global_mesh_enabled = false
          use_hub_gateway     = false
        }]

        hub = {
          resource_id   = module.networks["hub"].vnet.id
          resource_type = "Microsoft.Network/virtualNetworks"
        }
      }
    }
  }

  naming = local.naming
}


