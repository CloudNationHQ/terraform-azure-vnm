output "network_manager" {
  description = "contains virtual network manager configuration"
  value       = azurerm_network_manager.this
}

output "network_groups" {
  description = "contains network groups configuration"
  value       = azurerm_network_manager_network_group.this
}

output "connectivity_configurations" {
  description = "contains connectivity configurations"
  value       = azurerm_network_manager_connectivity_configuration.this
}

output "admin_configurations" {
  description = "contains security admin configurations"
  value       = azurerm_network_manager_security_admin_configuration.this
}

output "routing_configurations" {
  description = "contains routing configurations"
  value       = azurerm_network_manager_routing_configuration.this
}

output "deployments" {
  description = "contains network manager deployments"
  value       = azurerm_network_manager_deployment.this
}
