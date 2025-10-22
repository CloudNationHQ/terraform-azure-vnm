variable "config" {
  description = "virtual network manager configuration"
  type = object({
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

  validation {
    condition = (
      (var.config.management_group_ids != null && length(var.config.management_group_ids) > 0) ||
      (var.config.subscription_ids != null && length(var.config.subscription_ids) > 0)
    )
    error_message = "Either management_group_ids or subscription_ids must be provided and contain at least one item."
  }

  validation {
    condition     = var.config.location != null || var.location != null
    error_message = "location must be provided either in the network_manager object or as a separate variable."
  }

  validation {
    condition     = var.config.resource_group_name != null || var.resource_group_name != null
    error_message = "resource group name must be provided either in the network_manager object or as a separate variable."
  }

  validation {
    condition = alltrue([
      for scope_access in var.config.scope_accesses :
      contains(["Connectivity", "SecurityAdmin", "Routing"], scope_access)
    ])
    error_message = "scope_accesses must only contain: 'Connectivity', 'SecurityAdmin', or 'Routing'."
  }

  validation {
    condition     = var.config.location != null || var.location != null
    error_message = "location must be provided either in the config object or as a separate variable."
  }

  validation {
    condition     = var.config.resource_group_name != null || var.resource_group_name != null
    error_message = "resource group name must be provided either in the config object or as a separate variable."
  }

  validation {
    condition = alltrue([
      for deployment_key, deployment in var.config.deployments != null ? var.config.deployments : {} :
      contains(["Connectivity", "SecurityAdmin", "Routing"], deployment.scope_access)
    ])
    error_message = "scope_access must be one of: 'Connectivity', 'SecurityAdmin', or 'Routing'."
  }

  validation {
    condition = alltrue([
      for static_cidr in var.config.ipam_pool_static_cidrs != null ? values(var.config.ipam_pool_static_cidrs) : [] :
      (static_cidr.address_prefixes != null && length(static_cidr.address_prefixes) > 0) || static_cidr.number_of_ip_addresses_to_allocate != null
    ])
    error_message = "Each IPAM static CIDR must define address_prefixes or number_of_ip_addresses_to_allocate."
  }
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}

variable "naming" {
  description = "contains naming convention"
  type        = map(string)
  default     = {}
}
