locals {
  vnet = {
    # Hub VNet configuration
    hub = {
      name                = "${module.naming.virtual_network.name}-hub"
      location            = module.rg.groups.demo.location
      resource_group_name = module.rg.groups.demo.name
      address_space       = ["10.100.0.0/16"]

      tags = {
        environment = "demo"
        tier        = "hub"
      }
    }

    # Spoke VNet configuration
    spoke1 = {
      name                = "${module.naming.virtual_network.name}-spoke1"
      location            = module.rg.groups.demo.location
      resource_group_name = module.rg.groups.demo.name
      address_space       = ["10.101.0.0/16"]

      tags = {
        environment = "demo"
        tier        = "spoke"
      }
    }

    # Second Spoke VNet configuration
    spoke2 = {
      name                = "${module.naming.virtual_network.name}-spoke2"
      location            = module.rg.groups.demo.location
      resource_group_name = module.rg.groups.demo.name
      address_space       = ["10.102.0.0/16"]

      tags = {
        environment = "demo"
        tier        = "spoke"
      }
    }
  }
}
