# virtual network manager
resource "azurerm_network_manager" "vnm" {
  resource_group_name = coalesce(
    lookup(
      var.config, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.config, "location", null
    ), var.location
  )

  scope {
    management_group_ids = var.config.management_group_ids
    subscription_ids     = var.config.subscription_ids
  }
  name           = var.config.name
  description    = var.config.description
  scope_accesses = var.config.scope_accesses
  tags = coalesce(
    var.config.tags, var.tags
  )
}

# ipam pools
resource "azurerm_network_manager_ipam_pool" "ipam_pool" {
  for_each = try(var.config.ipam_pools, {})

  location = coalesce(
    each.value.location,
    lookup(var.config, "location", null),
    var.location
  )

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_ipam_pool, each.key]), null),
    each.key
  )
  network_manager_id = azurerm_network_manager.vnm.id
  address_prefixes   = each.value.address_prefixes
  description        = each.value.description
  display_name       = each.value.display_name
  parent_pool_name   = each.value.parent_pool_name
  tags = coalesce(
    var.config.tags, var.tags
  )
}

# ipam pool static cidrs
resource "azurerm_network_manager_ipam_pool_static_cidr" "static_cidr" {
  for_each = try(var.config.ipam_pool_static_cidrs, {})

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_ipam_pool_static_cidr, each.key]), null),
    each.key
  )
  ipam_pool_id = azurerm_network_manager_ipam_pool.ipam_pool[each.value.pool_key].id

  address_prefixes                   = each.value.address_prefixes
  number_of_ip_addresses_to_allocate = each.value.number_of_ip_addresses_to_allocate
}

# network groups
resource "azurerm_network_manager_network_group" "network_group" {
  for_each = try(var.config.network_groups, {})

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_network_group, each.key]), null),
    each.key
  )
  network_manager_id = azurerm_network_manager.vnm.id
  description        = each.value.description
}

# scope connections
resource "azurerm_network_manager_scope_connection" "scope_connection" {
  for_each = try(var.config.scope_connections, {})

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_scope_connection, each.key]), null),
    each.key
  )
  network_manager_id = azurerm_network_manager.vnm.id
  target_scope_id    = each.value.target_scope_id
  tenant_id          = each.value.tenant_id
  description        = each.value.description
}

# management group connections
resource "azurerm_network_manager_management_group_connection" "management_group_connection" {
  for_each = try(var.config.management_group_connections, {})

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_management_group_connection, each.key]), null),
    each.key
  )
  management_group_id = each.value.management_group_id
  network_manager_id  = azurerm_network_manager.vnm.id
  description         = each.value.description
}

# subscription connections
resource "azurerm_network_manager_subscription_connection" "subscription_connection" {
  for_each = try(var.config.subscription_connections, {})

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_subscription_connection, each.key]), null),
    each.key
  )
  subscription_id    = each.value.subscription_id
  network_manager_id = azurerm_network_manager.vnm.id
  description        = each.value.description
}

# connectivity configurations
resource "azurerm_network_manager_connectivity_configuration" "connectivity_configuration" {
  for_each = lookup(var.config, "connectivity_configurations", {})

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_connectivity_configuration, each.key]), null),
    each.key
  )
  network_manager_id              = azurerm_network_manager.vnm.id
  connectivity_topology           = each.value.connectivity_topology
  description                     = each.value.description
  global_mesh_enabled             = each.value.global_mesh_enabled
  delete_existing_peering_enabled = each.value.delete_existing_peering_enabled

  dynamic "applies_to_group" {
    for_each = each.value.applies_to_groups
    content {
      group_connectivity  = applies_to_group.value.group_connectivity
      network_group_id    = azurerm_network_manager_network_group.network_group[applies_to_group.value.network_group_key].id
      global_mesh_enabled = applies_to_group.value.global_mesh_enabled
      use_hub_gateway     = applies_to_group.value.use_hub_gateway
    }
  }

  dynamic "hub" {
    for_each = each.value.hub != null ? [each.value.hub] : []
    content {
      resource_id   = hub.value.resource_id
      resource_type = hub.value.resource_type
    }
  }
}

# static members
resource "azurerm_network_manager_static_member" "static_member" {
  for_each = lookup(var.config, "static_members", {})

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_static_member, each.key]), null),
    each.key
  )
  network_group_id          = azurerm_network_manager_network_group.network_group[each.value.network_group_key].id
  target_virtual_network_id = each.value.target_virtual_network_id
}

# routing configurations
resource "azurerm_network_manager_routing_configuration" "routing_configuration" {
  for_each = try(var.config.routing_configurations, {})

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_routing_configuration, each.key]), null),
    each.key
  )
  network_manager_id = azurerm_network_manager.vnm.id
  description        = each.value.description
}

# routing rule collections
resource "azurerm_network_manager_routing_rule_collection" "routing_rule_collection" {
  for_each = try(var.config.routing_rule_collections, {})

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_routing_rule_collection, each.key]), null),
    each.key
  )
  routing_configuration_id = azurerm_network_manager_routing_configuration.routing_configuration[each.value.routing_configuration_key].id
  network_group_ids = [
    for group_key in each.value.network_group_ids :
    azurerm_network_manager_network_group.network_group[group_key].id
  ]
  description = each.value.description
}

# security admin configurations
resource "azurerm_network_manager_security_admin_configuration" "admin_configuration" {
  for_each = try(var.config.admin_configurations, {})

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_security_admin_configuration, each.key]), null),
    each.key
  )
  network_manager_id                            = azurerm_network_manager.vnm.id
  description                                   = each.value.description
  apply_on_network_intent_policy_based_services = each.value.apply_on_network_intent_policy_based_services
}

# admin rule collections
resource "azurerm_network_manager_admin_rule_collection" "admin_rule_collection" {
  for_each = try(var.config.admin_rule_collections, {})

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_admin_rule_collection, each.key]), null),
    each.key
  )
  security_admin_configuration_id = azurerm_network_manager_security_admin_configuration.admin_configuration[each.value.admin_configuration_key].id
  network_group_ids = [
    for group_key in each.value.network_group_ids :
    azurerm_network_manager_network_group.network_group[group_key].id
  ]
  description = each.value.description
}

# admin rules
resource "azurerm_network_manager_admin_rule" "admin_rule" {
  for_each = try(var.config.admin_rules, {})

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_admin_rule, each.key]), null),
    each.key
  )
  admin_rule_collection_id = azurerm_network_manager_admin_rule_collection.admin_rule_collection[each.value.admin_rule_collection_key].id
  action                   = each.value.action
  direction                = each.value.direction
  priority                 = each.value.priority
  protocol                 = each.value.protocol
  source_port_ranges       = each.value.source_port_ranges
  destination_port_ranges  = each.value.destination_port_ranges
  description              = each.value.description

  dynamic "source" {
    for_each = try(each.value.source, [])
    content {
      address_prefix      = source.value.address_prefix
      address_prefix_type = source.value.address_prefix_type
    }
  }

  dynamic "destination" {
    for_each = try(each.value.destination, [])
    content {
      address_prefix      = destination.value.address_prefix
      address_prefix_type = destination.value.address_prefix_type
    }
  }
}

# verifier workspaces
resource "azurerm_network_manager_verifier_workspace" "verifier_workspace" {
  for_each = try(var.config.verifier_workspaces, {})

  location = coalesce(
    each.value.location,
    lookup(var.config, "location", null),
    var.location
  )

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_verifier_workspace, each.key]), null),
    each.key
  )
  network_manager_id = azurerm_network_manager.vnm.id
  description        = each.value.description
  tags = coalesce(
    var.config.tags, var.tags
  )
}

# verifier workspace reachability analysis intents
resource "azurerm_network_manager_verifier_workspace_reachability_analysis_intent" "reachability_analysis_intent" {
  for_each = try(var.config.reachability_analysis_intents, {})

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.network_manager_verifier_workspace_reachability_analysis_intent, each.key]), null),
    each.key
  )
  verifier_workspace_id   = azurerm_network_manager_verifier_workspace.verifier_workspace[each.value.verifier_workspace_key].id
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
resource "azurerm_network_manager_deployment" "deployment" {
  for_each = try(var.config.deployments, {})

  location = coalesce(
    each.value.location,
    lookup(var.config, "location", null),
    var.location
  )

  network_manager_id = azurerm_network_manager.vnm.id
  scope_access       = each.value.scope_access
  configuration_ids = [
    for config_key in each.value.configuration_ids :
    try(
      azurerm_network_manager_connectivity_configuration.connectivity_configuration[config_key].id,
      try(
        azurerm_network_manager_security_admin_configuration.admin_configuration[config_key].id,
        try(
          azurerm_network_manager_routing_configuration.routing_configuration[config_key].id,
          config_key
        )
      )
    )
  ]
  triggers = each.value.triggers

  # Ensure deployments wait for all configuration components to be created
  depends_on = [
    azurerm_network_manager_admin_rule.admin_rule,
    azurerm_network_manager_static_member.static_member
  ]
}
