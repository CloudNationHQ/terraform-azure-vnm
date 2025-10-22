output "config" {
  description = "contains virtual network manager configuration"
  value       = azurerm_network_manager.vnm
}

output "network_groups" {
  description = "contains network groups configuration"
  value       = azurerm_network_manager_network_group.network_group
}

output "connectivity_configurations" {
  description = "contains connectivity configurations"
  value       = azurerm_network_manager_connectivity_configuration.connectivity_configuration
}

output "admin_configurations" {
  description = "contains security admin configurations"
  value       = azurerm_network_manager_security_admin_configuration.admin_configuration
}

output "routing_configurations" {
  description = "contains routing configurations"
  value       = azurerm_network_manager_routing_configuration.routing_configuration
}

output "deployments" {
  description = "contains network manager deployments"
  value       = azurerm_network_manager_deployment.deployment
}
