module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

  suffix = ["demo", "security"]
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

module "vnets" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 9.0"

  for_each = local.vnets

  naming = local.naming
  vnet = {
    name                = each.value.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    address_space       = each.value.address_space

    subnets = {
      default = {
        address_prefixes = each.value.subnet_prefixes
      }
    }
  }
}

data "azurerm_subscription" "current" {}

module "virtual_network_manager" {
  source = "../.."

  config = {
    name                = module.naming.virtual_network_manager.name_unique
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location
    scope_accesses      = ["SecurityAdmin"]
    subscription_ids    = [data.azurerm_subscription.current.id]

    network_groups = {
      production_workloads = {
        name        = "production-workloads"
        description = "Production workloads requiring enhanced security"
      }
      development_workloads = {
        name        = "development-workloads"
        description = "Development workloads with standard security"
      }
    }

    static_members = {
      prod_web_member = {
        name                      = "prod-web-member"
        network_group_key         = "production_workloads"
        target_virtual_network_id = module.vnets["prod_web"].vnet.id
      }
      prod_api_member = {
        name                      = "prod-api-member"
        network_group_key         = "production_workloads"
        target_virtual_network_id = module.vnets["prod_api"].vnet.id
      }
      dev_web_member = {
        name                      = "dev-web-member"
        network_group_key         = "development_workloads"
        target_virtual_network_id = module.vnets["dev_web"].vnet.id
      }
      dev_api_member = {
        name                      = "dev-api-member"
        network_group_key         = "development_workloads"
        target_virtual_network_id = module.vnets["dev_api"].vnet.id
      }
    }


    admin_configurations = {
      security_baseline = {
        name                                          = "security-baseline-config"
        description                                   = "Baseline security configuration for all environments"
        apply_on_network_intent_policy_based_services = ["None"]
      }
    }

    admin_rule_collections = {
      security_rules = {
        name                    = "security-rules"
        admin_configuration_key = "security_baseline"
        network_group_ids       = ["production_workloads", "development_workloads"]
        description             = "Security rules applied to all workloads"
      }
    }

    admin_rules = {
      deny_rdp = {
        name                      = "deny-rdp"
        admin_rule_collection_key = "security_rules"
        action                    = "Deny"
        direction                 = "Inbound"
        priority                  = 100
        protocol                  = "Tcp"
        source_port_ranges        = ["1024-65535"]
        destination_port_ranges   = ["3389"]
        description               = "Block RDP access to all workloads"
        source = [{
          address_prefix      = "*"
          address_prefix_type = "IPPrefix"
        }]
        destination = [{
          address_prefix      = "*"
          address_prefix_type = "IPPrefix"
        }]
      }

      allow_https = {
        name                      = "allow-https"
        admin_rule_collection_key = "security_rules"
        action                    = "Allow"
        direction                 = "Inbound"
        priority                  = 200
        protocol                  = "Tcp"
        source_port_ranges        = ["1024-65535"]
        destination_port_ranges   = ["443"]
        description               = "Allow HTTPS access to all workloads"
        source = [{
          address_prefix      = "*"
          address_prefix_type = "IPPrefix"
        }]
        destination = [{
          address_prefix      = "*"
          address_prefix_type = "IPPrefix"
        }]
      }
    }

    deployments = {
      security_deployment = {
        location          = module.rg.groups.demo.location
        scope_access      = "SecurityAdmin"
        configuration_ids = ["security_baseline"]
      }
    }
  }

  naming = local.naming
}
