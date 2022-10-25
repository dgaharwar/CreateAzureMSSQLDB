# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.19.0"
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

resource "azurerm_mssql_server" "main-mssql-server" {
  name                          = var.mssqlServerName
  resource_group_name           = data.azurerm_resource_group.selected-rg.name
  location                      = data.azurerm_resource_group.selected-rg.location
  version                       = "12.0"
  administrator_login           = var.adminUser
  administrator_login_password  = var.adminPassword
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  /*
  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = "00000000-0000-0000-0000-000000000000"
  }

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.example.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.example.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }
  */
  /*
  tags = {
    environment = "production"
  }
  */
}

# resource "azurerm_sql_virtual_network_rule" "sql-vnet-rule" {
#   count               = length(data.azurerm_virtual_network.selected-vnet.subnets)
#   name                = "${var.mssqlServerName}-vnet-rule-${count.index}"
#   resource_group_name = data.azurerm_resource_group.selected-rg.name
#   server_name         = azurerm_mssql_server.main-mssql-server.name
#   subnet_id           = data.azurerm_subnet.subnets[count.index].id

#   depends_on = [azurerm_mssql_server.main-mssql-server]
# }

# resource "azurerm_sql_virtual_network_rule" "sql-admin-vnet-rule" {
#   name                = "omhs-admin-vnet-rule"
#   resource_group_name = data.azurerm_resource_group.selected-rg.name
#   server_name         = azurerm_mssql_server.main-mssql-server.name
#   subnet_id           = data.azurerm_subnet.admin-subnet.id

#   depends_on = [azurerm_mssql_server.main-mssql-server]
# }

resource "azurerm_mssql_database" "main-db" {
  name         = var.mssqlDBName
  server_id    = azurerm_mssql_server.main-mssql-server.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = var.maxSizeGB
  //read_scale     = true
  sku_name             = var.mssqlSKU
  storage_account_type = "Geo"
  zone_redundant       = true
  // Below attributes need to be set for SKU General Purpose Serverless
  min_capacity = substr(var.mssqlSKU, 0, 4) == "GP_S" ? var.minCapacity[var.mssqlSKU] : null

  auto_pause_delay_in_minutes = substr(var.mssqlSKU, 0, 4) == "GP_S" ? 60 : null

  short_term_retention_policy {
    retention_days = var.backupRetentionDays
  }

  lifecycle {
    ignore_changes = all
  }

  /*
  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.example.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.example.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }
  */
  /*
  tags = {
    environment = "production"
  }
  */
}

/*
output "test" {
  value = substr(var.mssqlSKU, 0, 4)
}
*/

# resource "azurerm_sql_firewall_rule" "fw-rule" {
#   name                = "${var.mssqlServerName}-fw-rule"
#   resource_group_name = data.azurerm_resource_group.selected-rg.name
#   server_name         = azurerm_mssql_server.main-mssql-server.name
#   start_ip_address    = var.startIPAddress
#   end_ip_address      = var.endIPAddress
# }

resource "azurerm_private_endpoint" "privateendpoint" {
  name                = "${var.mssqlServerName}-ep"
  location            = data.azurerm_resource_group.selected-rg.location
  resource_group_name = data.azurerm_resource_group.selected-rg.name
  subnet_id           = data.azurerm_subnet.selected-subnet.id

  # private_dns_zone_group {
  #   name = "privatednszonegroup"
  #   private_dns_zone_ids = [azurerm_private_dns_zone.dnsprivatezone.id]
  # }

  private_service_connection {
    name                           = "privateendpointconnection"
    private_connection_resource_id = azurerm_mssql_server.main-mssql-server.id
    subresource_names              = ["sqlServer"]
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
