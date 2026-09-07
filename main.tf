# virtual network manager
resource "azurerm_network_manager" "this" {
  resource_group_name = coalesce(
    var.network_manager.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.network_manager.location, var.location
  )

  name           = var.network_manager.name
  description    = var.network_manager.description
  scope_accesses = var.network_manager.scope_accesses

  scope {
    management_group_ids = var.network_manager.management_group_ids
    subscription_ids     = var.network_manager.subscription_ids
  }

  tags = coalesce(
    var.network_manager.tags, var.tags
  )
}

# ipam pools
resource "azurerm_network_manager_ipam_pool" "this" {
  for_each = var.network_manager.ipam_pools

  location = coalesce(
    each.value.location,
    var.network_manager.location,
    var.location
  )

  name = coalesce(
    each.value.name,
    each.key
  )

  network_manager_id = azurerm_network_manager.this.id
  address_prefixes   = each.value.address_prefixes
  description        = each.value.description
  display_name       = each.value.display_name
  parent_pool_name   = each.value.parent_pool_name

  tags = coalesce(
    var.network_manager.tags, var.tags
  )
}

# ipam pool static cidrs
resource "azurerm_network_manager_ipam_pool_static_cidr" "this" {
  for_each = var.network_manager.ipam_pool_static_cidrs

  name = coalesce(
    each.value.name,
    each.key
  )

  ipam_pool_id                       = azurerm_network_manager_ipam_pool.this[each.value.pool_key].id
  address_prefixes                   = each.value.address_prefixes
  number_of_ip_addresses_to_allocate = each.value.number_of_ip_addresses_to_allocate
}

# network groups
resource "azurerm_network_manager_network_group" "this" {
  for_each = var.network_manager.network_groups

  name = coalesce(
    each.value.name,
    each.key
  )

  network_manager_id = azurerm_network_manager.this.id
  description        = each.value.description
  member_type        = each.value.member_type
}

# scope connections
resource "azurerm_network_manager_scope_connection" "this" {
  for_each = var.network_manager.scope_connections

  name = coalesce(
    each.value.name,
    each.key
  )

  network_manager_id = azurerm_network_manager.this.id
  target_scope_id    = each.value.target_scope_id
  tenant_id          = each.value.tenant_id
  description        = each.value.description
}

# management group connections
resource "azurerm_network_manager_management_group_connection" "this" {
  for_each = var.network_manager.management_group_connections

  name = coalesce(
    each.value.name,
    each.key
  )

  management_group_id = each.value.management_group_id
  network_manager_id  = azurerm_network_manager.this.id
  description         = each.value.description
}

# subscription connections
resource "azurerm_network_manager_subscription_connection" "this" {
  for_each = var.network_manager.subscription_connections

  name = coalesce(
    each.value.name,
    each.key
  )

  subscription_id    = each.value.subscription_id
  network_manager_id = azurerm_network_manager.this.id
  description        = each.value.description
}

# connectivity configurations
resource "azurerm_network_manager_connectivity_configuration" "this" {
  for_each = var.network_manager.connectivity_configurations

  name = coalesce(
    each.value.name,
    each.key
  )

  network_manager_id                      = azurerm_network_manager.this.id
  connectivity_topology                   = each.value.connectivity_topology
  description                             = each.value.description
  global_mesh_enabled                     = each.value.global_mesh_enabled
  delete_existing_peering_enabled         = each.value.delete_existing_peering_enabled
  connected_group_address_overlap_enabled = each.value.connected_group_address_overlap_enabled
  connected_group_private_endpoints_scale = each.value.connected_group_private_endpoints_scale
  peering_enforcement_enabled             = each.value.peering_enforcement_enabled

  dynamic "applies_to_group" {
    for_each = each.value.applies_to_groups

    content {
      group_connectivity  = applies_to_group.value.group_connectivity
      network_group_id    = azurerm_network_manager_network_group.this[applies_to_group.value.network_group_key].id
      global_mesh_enabled = applies_to_group.value.global_mesh_enabled
      use_hub_gateway     = applies_to_group.value.use_hub_gateway
    }
  }

  dynamic "hub" {
    for_each = each.value.hub != null ? { "this" = each.value.hub } : {}

    content {
      resource_id   = hub.value.resource_id
      resource_type = hub.value.resource_type
    }
  }
}

# static members
resource "azurerm_network_manager_static_member" "this" {
  for_each = var.network_manager.static_members

  name = coalesce(
    each.value.name,
    each.key
  )

  network_group_id          = azurerm_network_manager_network_group.this[each.value.network_group_key].id
  target_virtual_network_id = each.value.target_virtual_network_id
}

# routing configurations
resource "azurerm_network_manager_routing_configuration" "this" {
  for_each = var.network_manager.routing_configurations

  name = coalesce(
    each.value.name,
    each.key
  )

  network_manager_id     = azurerm_network_manager.this.id
  description            = each.value.description
  route_table_usage_mode = each.value.route_table_usage_mode
}

# routing rule collections
resource "azurerm_network_manager_routing_rule_collection" "this" {
  for_each = var.network_manager.routing_rule_collections

  name = coalesce(
    each.value.name,
    each.key
  )

  routing_configuration_id      = azurerm_network_manager_routing_configuration.this[each.value.routing_configuration_key].id
  description                   = each.value.description
  bgp_route_propagation_enabled = each.value.bgp_route_propagation_enabled

  network_group_ids = [
    for group_key in each.value.network_group_ids :
    azurerm_network_manager_network_group.this[group_key].id
  ]
}

# security admin configurations
resource "azurerm_network_manager_security_admin_configuration" "this" {
  for_each = var.network_manager.admin_configurations

  name = coalesce(
    each.value.name,
    each.key
  )

  network_manager_id                            = azurerm_network_manager.this.id
  description                                   = each.value.description
  apply_on_network_intent_policy_based_services = each.value.apply_on_network_intent_policy_based_services
}

# admin rule collections
resource "azurerm_network_manager_admin_rule_collection" "this" {
  for_each = var.network_manager.admin_rule_collections

  name = coalesce(
    each.value.name,
    each.key
  )

  security_admin_configuration_id = azurerm_network_manager_security_admin_configuration.this[each.value.admin_configuration_key].id
  description                     = each.value.description

  network_group_ids = [
    for group_key in each.value.network_group_ids :
    azurerm_network_manager_network_group.this[group_key].id
  ]
}

# admin rules
resource "azurerm_network_manager_admin_rule" "this" {
  for_each = var.network_manager.admin_rules

  name = coalesce(
    each.value.name,
    each.key
  )

  admin_rule_collection_id = azurerm_network_manager_admin_rule_collection.this[each.value.admin_rule_collection_key].id
  action                   = each.value.action
  direction                = each.value.direction
  priority                 = each.value.priority
  protocol                 = each.value.protocol
  source_port_ranges       = each.value.source_port_ranges
  destination_port_ranges  = each.value.destination_port_ranges
  description              = each.value.description

  dynamic "source" {
    for_each = each.value.source

    content {
      address_prefix      = source.value.address_prefix
      address_prefix_type = source.value.address_prefix_type
    }
  }

  dynamic "destination" {
    for_each = each.value.destination

    content {
      address_prefix      = destination.value.address_prefix
      address_prefix_type = destination.value.address_prefix_type
    }
  }
}

# verifier workspaces
resource "azurerm_network_manager_verifier_workspace" "this" {
  for_each = var.network_manager.verifier_workspaces

  location = coalesce(
    each.value.location,
    var.network_manager.location,
    var.location
  )

  name = coalesce(
    each.value.name,
    each.key
  )

  network_manager_id = azurerm_network_manager.this.id
  description        = each.value.description

  tags = coalesce(
    var.network_manager.tags, var.tags
  )
}

# verifier workspace reachability analysis intents
resource "azurerm_network_manager_verifier_workspace_reachability_analysis_intent" "this" {
  for_each = var.network_manager.reachability_analysis_intents

  name = coalesce(
    each.value.name,
    each.key
  )

  verifier_workspace_id   = azurerm_network_manager_verifier_workspace.this[each.value.verifier_workspace_key].id
  destination_resource_id = each.value.destination_resource_id
  source_resource_id      = each.value.source_resource_id
  description             = each.value.description

  ip_traffic {
    source_ips        = each.value.ip_traffic.source_ips
    destination_ips   = each.value.ip_traffic.destination_ips
    source_ports      = each.value.ip_traffic.source_ports
    destination_ports = each.value.ip_traffic.destination_ports
    protocols         = each.value.ip_traffic.protocols
  }
}

# network manager deployment
resource "azurerm_network_manager_deployment" "this" {
  for_each = var.network_manager.deployments

  location = coalesce(
    each.value.location,
    var.network_manager.location,
    var.location
  )

  network_manager_id = azurerm_network_manager.this.id
  scope_access       = each.value.scope_access
  triggers           = each.value.triggers

  configuration_ids = [
    for config_key in each.value.configuration_ids :
    try(
      azurerm_network_manager_connectivity_configuration.this[config_key].id,
      try(
        azurerm_network_manager_security_admin_configuration.this[config_key].id,
        try(
          azurerm_network_manager_routing_configuration.this[config_key].id,
          config_key
        )
      )
    )
  ]
  depends_on = [
    azurerm_network_manager_admin_rule.this,
    azurerm_network_manager_static_member.this
  ]
}
