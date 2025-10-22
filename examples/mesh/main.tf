module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

  suffix = ["demo", "mesh"]
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
      mesh_networks = {
        name        = "mesh-networks"
        description = "Network group for full mesh connectivity between all networks"
      }
      prod_networks = {
        name        = "prod-networks"
        description = "Production network group for isolated production workloads"
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
      prod_member = {
        network_group_key         = "prod_networks"
        name                      = "prod-member"
        target_virtual_network_id = module.networks["prod"].vnet.id
      }
    }

    connectivity_configurations = {
      mesh = {
        name                  = "mesh-connectivity"
        description           = "Full mesh connectivity configuration for all demo networks"
        connectivity_topology = "Mesh"
        global_mesh_enabled   = true

        applies_to_groups = [
          {
            network_group_key   = "mesh_networks"
            group_connectivity  = "DirectlyConnected"
            global_mesh_enabled = true
            use_hub_gateway     = false
          },
          {
            network_group_key   = "prod_networks"
            group_connectivity  = "DirectlyConnected"
            global_mesh_enabled = true
            use_hub_gateway     = false
          }
        ]
      }
    }

    deployments = {
      mesh_deployment = {
        scope_access      = "Connectivity"
        configuration_ids = ["mesh"]
        triggers = {
          connectivity_config = "mesh"
          timestamp           = "2025-10-13"
        }
      }
    }
  }

  naming = local.naming
}
