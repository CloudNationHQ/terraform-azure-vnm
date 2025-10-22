# Virtual Network Manager

This terraform module simplifies the process of creating and managing Azure Virtual Network Manager with customizable options and features, offering a flexible and powerful solution for managing azure network connectivity, security, and IPAM through code.

## Features

Offers support for connectivity configurations with hub-and-spoke and mesh topologies.

Employs security admin configurations with rule collections and admin rules.

Provides IPAM pools for centralized IP address allocation and management.

Utilization of terratest for robust validation.

Facilitates network groups to organize virtual networks by connectivity and security requirements.

Supports routing configurations and rule collections for advanced traffic management.

Integrates seamlessly with Azure Policy for dynamic network group membership.

Support for verifier workspaces and reachability analysis intents for network diagnostics.

Enables deployments across multiple scopes (Connectivity, SecurityAdmin, Routing).

Supports static members for explicit virtual network assignments to network groups.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_network_manager.vnm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager) (resource)
- [azurerm_network_manager_admin_rule.admin_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_admin_rule) (resource)
- [azurerm_network_manager_admin_rule_collection.admin_rule_collection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_admin_rule_collection) (resource)
- [azurerm_network_manager_connectivity_configuration.connectivity_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_connectivity_configuration) (resource)
- [azurerm_network_manager_deployment.deployment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_deployment) (resource)
- [azurerm_network_manager_ipam_pool.ipam_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_ipam_pool) (resource)
- [azurerm_network_manager_ipam_pool_static_cidr.static_cidr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_ipam_pool_static_cidr) (resource)
- [azurerm_network_manager_management_group_connection.management_group_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_management_group_connection) (resource)
- [azurerm_network_manager_network_group.network_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_network_group) (resource)
- [azurerm_network_manager_routing_configuration.routing_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_routing_configuration) (resource)
- [azurerm_network_manager_routing_rule_collection.routing_rule_collection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_routing_rule_collection) (resource)
- [azurerm_network_manager_scope_connection.scope_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_scope_connection) (resource)
- [azurerm_network_manager_security_admin_configuration.admin_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_security_admin_configuration) (resource)
- [azurerm_network_manager_static_member.static_member](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_static_member) (resource)
- [azurerm_network_manager_subscription_connection.subscription_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_subscription_connection) (resource)
- [azurerm_network_manager_verifier_workspace.verifier_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_verifier_workspace) (resource)
- [azurerm_network_manager_verifier_workspace_reachability_analysis_intent.reachability_analysis_intent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_verifier_workspace_reachability_analysis_intent) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_config"></a> [config](#input\_config)

Description: virtual network manager configuration

Type:

```hcl
object({
    name                 = string
    scope_accesses       = list(string)
    description          = optional(string)
    resource_group_name  = optional(string)
    location             = optional(string)
    tags                 = optional(map(string))
    management_group_ids = optional(list(string), [])
    subscription_ids     = optional(list(string), [])
    ipam_pools = optional(map(object({
      name             = string
      address_prefixes = list(string)
      location         = optional(string)
      description      = optional(string)
      display_name     = optional(string)
      parent_pool_name = optional(string)
    })), {})
    ipam_pool_static_cidrs = optional(map(object({
      name                               = string
      pool_key                           = string
      address_prefixes                   = optional(list(string))
      number_of_ip_addresses_to_allocate = optional(number)
    })), {})
    network_groups = optional(map(object({
      name        = string
      description = optional(string)
    })), {})
    scope_connections = optional(map(object({
      name            = string
      target_scope_id = string
      tenant_id       = string
      description     = optional(string)
    })), {})
    management_group_connections = optional(map(object({
      name                = string
      management_group_id = string
      description         = optional(string)
    })), {})
    subscription_connections = optional(map(object({
      name            = string
      subscription_id = string
      description     = optional(string)
    })), {})
    connectivity_configurations = optional(map(object({
      name                            = string
      connectivity_topology           = string
      description                     = optional(string)
      global_mesh_enabled             = optional(bool)
      delete_existing_peering_enabled = optional(bool)
      applies_to_groups = list(object({
        group_connectivity  = string
        network_group_key   = string
        global_mesh_enabled = optional(bool)
        use_hub_gateway     = optional(bool)
      }))
      hub = optional(object({
        resource_id   = string
        resource_type = string
      }))
    })), {})
    static_members = optional(map(object({
      name                      = string
      network_group_key         = string
      target_virtual_network_id = string
    })), {})
    routing_configurations = optional(map(object({
      name        = string
      description = optional(string)
    })), {})
    routing_rule_collections = optional(map(object({
      name                      = string
      routing_configuration_key = string
      network_group_ids         = list(string)
      description               = optional(string)
    })), {})
    admin_configurations = optional(map(object({
      name                                          = string
      description                                   = optional(string)
      apply_on_network_intent_policy_based_services = optional(list(string))
    })), {})
    admin_rule_collections = optional(map(object({
      name                    = string
      admin_configuration_key = string
      network_group_ids       = list(string)
      description             = optional(string)
    })), {})
    admin_rules = optional(map(object({
      name                      = string
      admin_rule_collection_key = string
      action                    = string
      direction                 = string
      priority                  = number
      protocol                  = string
      source_port_ranges        = optional(list(string))
      destination_port_ranges   = optional(list(string))
      description               = optional(string)
      source = list(object({
        address_prefix      = string
        address_prefix_type = string
      }))
      destination = list(object({
        address_prefix      = string
        address_prefix_type = string
      }))
    })), {})
    verifier_workspaces = optional(map(object({
      name        = string
      location    = optional(string)
      description = optional(string)
    })), {})
    reachability_analysis_intents = optional(map(object({
      name                    = string
      verifier_workspace_key  = string
      description             = optional(string)
      source_resource_id      = string
      destination_resource_id = string
      ip_traffic = object({
        source_ips        = list(string)
        destination_ips   = list(string)
        source_ports      = list(string)
        destination_ports = list(string)
        protocols         = list(string)
      })
    })), {})
    deployments = optional(map(object({
      location          = optional(string)
      scope_access      = string
      configuration_ids = list(string)
      triggers          = optional(map(string), {})
    })), {})
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_naming"></a> [naming](#input\_naming)

Description: contains naming convention

Type: `map(string)`

Default: `{}`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_admin_configurations"></a> [admin\_configurations](#output\_admin\_configurations)

Description: contains security admin configurations

### <a name="output_config"></a> [config](#output\_config)

Description: contains virtual network manager configuration

### <a name="output_connectivity_configurations"></a> [connectivity\_configurations](#output\_connectivity\_configurations)

Description: contains connectivity configurations

### <a name="output_deployments"></a> [deployments](#output\_deployments)

Description: contains network manager deployments

### <a name="output_network_groups"></a> [network\_groups](#output\_network\_groups)

Description: contains network groups configuration

### <a name="output_routing_configurations"></a> [routing\_configurations](#output\_routing\_configurations)

Description: contains routing configurations
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-vnm/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-vnm" />
</a>

## License

MIT Licensed. See [LICENSE](https://github.com/cloudnationhq/terraform-azure-vnm/blob/main/LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/virtual-network-manager/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/networkmanager/)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/tree/1f449b5a17448f05ce1cd914f8ed75a0b568d130/specification/network)
