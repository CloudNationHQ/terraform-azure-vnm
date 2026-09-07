moved {
  from = azurerm_network_manager.vnm
  to   = azurerm_network_manager.this
}

moved {
  from = azurerm_network_manager_ipam_pool.ipam_pool
  to   = azurerm_network_manager_ipam_pool.this
}

moved {
  from = azurerm_network_manager_ipam_pool_static_cidr.static_cidr
  to   = azurerm_network_manager_ipam_pool_static_cidr.this
}

moved {
  from = azurerm_network_manager_network_group.network_group
  to   = azurerm_network_manager_network_group.this
}

moved {
  from = azurerm_network_manager_scope_connection.scope_connection
  to   = azurerm_network_manager_scope_connection.this
}

moved {
  from = azurerm_network_manager_management_group_connection.management_group_connection
  to   = azurerm_network_manager_management_group_connection.this
}

moved {
  from = azurerm_network_manager_subscription_connection.subscription_connection
  to   = azurerm_network_manager_subscription_connection.this
}

moved {
  from = azurerm_network_manager_connectivity_configuration.connectivity_configuration
  to   = azurerm_network_manager_connectivity_configuration.this
}

moved {
  from = azurerm_network_manager_static_member.static_member
  to   = azurerm_network_manager_static_member.this
}

moved {
  from = azurerm_network_manager_routing_configuration.routing_configuration
  to   = azurerm_network_manager_routing_configuration.this
}

moved {
  from = azurerm_network_manager_routing_rule_collection.routing_rule_collection
  to   = azurerm_network_manager_routing_rule_collection.this
}

moved {
  from = azurerm_network_manager_security_admin_configuration.admin_configuration
  to   = azurerm_network_manager_security_admin_configuration.this
}

moved {
  from = azurerm_network_manager_admin_rule_collection.admin_rule_collection
  to   = azurerm_network_manager_admin_rule_collection.this
}

moved {
  from = azurerm_network_manager_admin_rule.admin_rule
  to   = azurerm_network_manager_admin_rule.this
}

moved {
  from = azurerm_network_manager_verifier_workspace.verifier_workspace
  to   = azurerm_network_manager_verifier_workspace.this
}

moved {
  from = azurerm_network_manager_verifier_workspace_reachability_analysis_intent.reachability_analysis_intent
  to   = azurerm_network_manager_verifier_workspace_reachability_analysis_intent.this
}

moved {
  from = azurerm_network_manager_deployment.deployment
  to   = azurerm_network_manager_deployment.this
}
