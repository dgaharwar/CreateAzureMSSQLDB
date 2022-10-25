# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.22.0"
    }
  }
  required_version = ">= 0.14.1"
}

provider "azurerm" {
  features {}

  subscription_id = var.subscriptionId
  tenant_id       = var.tenantId
  client_id       = var.clientId
  client_secret   = var.clientSecret
}

# provider "azurerm" {
#   features {}

#   subscription_id            = var.subscription_id_msp
#   client_id                  = var.client_id
#   client_secret              = var.client_secret
#   tenant_id                  = var.tenant_id
#   skip_provider_registration = true
#   #auxiliary_tenant_ids = [ var.tenant_id ]

#   alias = "mspsub"
# }

data "azurerm_virtual_network" "selected-vnet" {
  name                = var.vNet
  resource_group_name = var.resourceGroup
}

data "azurerm_subnet" "subnets" {
  count                = length(data.azurerm_virtual_network.selected-vnet.subnets)
  name                 = data.azurerm_virtual_network.selected-vnet.subnets[count.index]
  virtual_network_name = var.vNet
  resource_group_name  = var.resourceGroup
}

# data "azurerm_subnet" "admin-subnet" {
#   provider             = azurerm.mspsub
#   name                 = var.subnetOmhsDBA
#   virtual_network_name = var.vNetOmhsDBA
#   resource_group_name  = var.resourceGroupOmhsDBA
# }

data "azurerm_subnet" "selected-subnet" {
  name                 = var.subnet
  virtual_network_name = var.vNet
  resource_group_name  = var.resourceGroup
}

data "azurerm_resource_group" "selected-rg" {
  name = var.resourceGroup
}

resource "azurerm_mysql_server" "mysql-server" {
  name                = var.mysqlServerName
  location            = data.azurerm_resource_group.selected-rg.location
  resource_group_name = data.azurerm_resource_group.selected-rg.name

  administrator_login          = var.adminUser
  administrator_login_password = var.adminPassword

  sku_name   = var.mysqlServerSKU
  storage_mb = var.storageSizeGB * 1024
  version    = var.mysqlVersion

  auto_grow_enabled                 = true
  backup_retention_days             = var.backupRetentionDays
  geo_redundant_backup_enabled      = var.enableGeoRedundateBackup
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

}

# resource "azurerm_mysql_virtual_network_rule" "mysql-vnet-rule" {
#   count               = length(data.azurerm_virtual_network.selected-vnet.subnets)
#   name                = "${var.mysqlServerName}-vnet-rule-${count.index}"
#   resource_group_name = data.azurerm_resource_group.selected-rg.name
#   server_name         = azurerm_mysql_server.mysql-server.name
#   subnet_id           = data.azurerm_subnet.subnets[count.index].id

#   depends_on = [azurerm_mysql_server.mysql-server]
# }

# resource "azurerm_mysql_virtual_network_rule" "mysql-admin-vnet-rule" {
#   name                = "omhs-admin-vnet-rule"
#   resource_group_name = data.azurerm_resource_group.selected-rg.name
#   server_name         = azurerm_mysql_server.mysql-server.name
#   subnet_id           = data.azurerm_subnet.admin-subnet.id

#   depends_on = [azurerm_mysql_server.mysql-server]
# }

resource "azurerm_mysql_database" "mysql-database" {
  name                = var.mysqlDBName
  resource_group_name = data.azurerm_resource_group.selected-rg.name
  server_name         = azurerm_mysql_server.mysql-server.name
  charset             = var.charset
  collation           = var.collation
  lifecycle {
    ignore_changes = all
  }

}

# resource "azurerm_mysql_firewall_rule" "main-fw-rule" {
#   name                = "${var.mysqlServerName}-fw-rule"
#   resource_group_name = data.azurerm_resource_group.selected-rg.name
#   server_name         = azurerm_mysql_server.mysql-server.name
#   start_ip_address    = var.startIPAddress
#   end_ip_address      = var.endIPAddress
# }

resource "azurerm_private_endpoint" "privateendpoint" {
  name                = "${var.mysqlServerName}-ep"
  location            = data.azurerm_resource_group.selected-rg.location
  resource_group_name = data.azurerm_resource_group.selected-rg.name
  subnet_id           = data.azurerm_subnet.selected-subnet.id

  # private_dns_zone_group {
  #   name = "privatednszonegroup"
  #   private_dns_zone_ids = [azurerm_private_dns_zone.dnsprivatezone.id]
  # }

  private_service_connection {
    name                           = "privateendpointconnection"
    private_connection_resource_id = azurerm_mysql_server.mysql-server.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

}

output "privateIPaddress" {
  value = azurerm_private_endpoint.privateendpoint.private_service_connection[0].private_ip_address
}

# output "subnets" {
#   value = data.azurerm_virtual_network.selected-vnet.subnets
# }
