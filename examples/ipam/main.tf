module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

  suffix = ["demo", "ipam"]
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

data "azurerm_subscription" "current" {}

module "virtual_network_manager" {
  source  = "cloudnationhq/vnm/azure"
  version = "~> 1.0"

  config = {
    name                = module.naming.virtual_network_manager.name_unique
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location
    scope_accesses      = ["Connectivity"]
    subscription_ids    = [data.azurerm_subscription.current.id]

    ipam_pools = {
      dev_pool = {
        name             = "dev-pool"
        display_name     = "Development-Pool"
        description      = "IPAM pool for development workloads"
        address_prefixes = ["10.100.0.0/16"]
        parent_pool_name = null
      }

      tst_pool = {
        name             = "tst-pool"
        display_name     = "Test-Pool"
        description      = "IPAM pool for test workloads"
        address_prefixes = ["10.101.0.0/16"]
        parent_pool_name = null
      }

      acc_pool = {
        name             = "acc-pool"
        display_name     = "Acceptance-Pool"
        description      = "IPAM pool for acceptance workloads"
        address_prefixes = ["10.102.0.0/16"]
        parent_pool_name = null
      }

      prd_pool = {
        name             = "prd-pool"
        display_name     = "Production-Pool"
        description      = "IPAM pool for production workloads"
        address_prefixes = ["10.103.0.0/16"]
        parent_pool_name = null
      }
    }

    ipam_pool_static_cidrs = {
      dev_ip_reservation = {
        name             = "dev-reserved-ips"
        pool_key         = "dev_pool"
        address_prefixes = ["10.100.10.0/24"]
      }

      prd_ip_reservation = {
        name             = "prd-reserved-ips"
        pool_key         = "prd_pool"
        address_prefixes = ["10.103.20.0/22"]
      }

      tst_ip_reservation = {
        name                               = "tst-reserved-ips"
        pool_key                           = "tst_pool"
        number_of_ip_addresses_to_allocate = "256"
      }
    }
  }
}
