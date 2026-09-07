module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.32"

  suffix = ["demo", "mesh"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 3.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "networks" {
  source   = "cloudnationhq/vnet/azure"
  version  = "~> 10.0"
  for_each = local.vnet

  vnet   = each.value
}

data "azurerm_subscription" "current" {}

module "virtual_network_manager" {
  source  = "cloudnationhq/vnm/azure"
  version = "~> 2.0"

  network_manager = {
    name                = module.naming.virtual_network_manager.name_unique
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location
    scope_accesses      = ["Connectivity"]
    subscription_ids    = [data.azurerm_subscription.current.id]

    network_groups = {
      mesh_networks = {
        name        = "mesh-networks"
        description = "Network group for full mesh connectivity between all networks"
      }
    }

    static_members = {
      hub_member = {
        network_group_key         = "mesh_networks"
        name                      = "hub-member"
        target_virtual_network_id = module.networks["hub"].vnet.id
      }
      spoke1_member = {
        network_group_key         = "mesh_networks"
        name                      = "spoke1-member"
        target_virtual_network_id = module.networks["spoke1"].vnet.id
      }
      spoke2_member = {
        network_group_key         = "mesh_networks"
        name                      = "spoke2-member"
        target_virtual_network_id = module.networks["spoke2"].vnet.id
      }
    }

    connectivity_configurations = {
      mesh = {
        name                  = "mesh-connectivity"
        description           = "Full mesh connectivity configuration"
        connectivity_topology = "Mesh"
        global_mesh_enabled   = true

        applies_to_groups = [{
            network_group_key   = "mesh_networks"
            group_connectivity  = "DirectlyConnected"
            global_mesh_enabled = true
            use_hub_gateway     = false
          }]
      }
    }
  }

}
