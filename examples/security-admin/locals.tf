locals {
  vnets = {
    prod_web = {
      name            = "vnet-prod-web"
      address_space   = ["10.1.0.0/16"]
      subnet_prefixes = ["10.1.1.0/24"]
    }
    prod_api = {
      name            = "vnet-prod-api"
      address_space   = ["10.2.0.0/16"]
      subnet_prefixes = ["10.2.1.0/24"]
    }
    dev_web = {
      name            = "vnet-dev-web"
      address_space   = ["10.10.0.0/16"]
      subnet_prefixes = ["10.10.1.0/24"]
    }
    dev_api = {
      name            = "vnet-dev-api"
      address_space   = ["10.11.0.0/16"]
      subnet_prefixes = ["10.11.1.0/24"]
    }
  }
}
