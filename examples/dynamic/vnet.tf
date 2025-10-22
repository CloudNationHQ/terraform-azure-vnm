locals {
  vnet = {
    hub = {
      name                = "vnet-dynamic-tst-hub"
      location            = module.rg.groups.demo.location
      resource_group_name = module.rg.groups.demo.name
      address_space       = ["10.200.0.0/16"]
    }

    spoke1 = {
      name                = "vnet-dynamic-tst-spoke1"
      location            = module.rg.groups.demo.location
      resource_group_name = module.rg.groups.demo.name
      address_space       = ["10.201.0.0/16"]
    }

    spoke2 = {
      name                = "vnet-dynamic-tst-spoke2"
      location            = module.rg.groups.demo.location
      resource_group_name = module.rg.groups.demo.name
      address_space       = ["10.202.0.0/16"]
    }

    spoke3 = {
      name                = "vnet-dynamic-tst-spoke3"
      location            = module.rg.groups.demo.location
      resource_group_name = module.rg.groups.demo.name
      address_space       = ["10.203.0.0/16"]
    }
  }
}
