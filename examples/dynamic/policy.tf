resource "random_id" "policy_suffix" {
  byte_length = 4
}

resource "azurerm_policy_definition" "network_group_policy" {
  name         = "network-group-policy-${random_id.policy_suffix.hex}"
  policy_type  = "Custom"
  mode         = "Microsoft.Network.Data"
  display_name = "Policy Definition for Dynamic Network Group"

  metadata = <<METADATA
    {
      "category": "Azure Virtual Network Manager"
    }
  METADATA

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Network/virtualNetworks"
        },
        {
          field    = "Name"
          contains = "vnet-dynamic-tst"
        }
      ]
    }
    then = {
      effect = "addToNetworkGroup"
      details = {
        networkGroupId = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${module.rg.groups.demo.name}/providers/Microsoft.Network/networkManagers/${module.virtual_network_manager.config.name}/networkGroups/dynamic-networks"
      }
    }
  })
}

resource "azurerm_subscription_policy_assignment" "azure_policy_assignment" {
  name                 = "network-group-policy-${random_id.policy_suffix.hex}-assignment"
  policy_definition_id = azurerm_policy_definition.network_group_policy.id
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Dynamic Network Group Policy Assignment"
  description          = "Automatically adds VNets matching naming pattern to Network Manager group"
}
