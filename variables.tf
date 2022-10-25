# variable "subscription_id_msp" {
#   type      = string
#   sensitive = true
#   #default = "<%= customOptions.azurergprep_subscriptionid %>"
# }

variable "subscriptionId" {
  type      = string
  sensitive = true
  #default = "<%= customOptions.azurergprep_subscriptionid %>"
}
variable "tenantId" {
  type      = string
  sensitive = true
  #default = "<%= customOptions.azurergprep_tenantid %>"
}
variable "clientId" {
  type      = string
  sensitive = true
  #default = "<%= customOptions.azurergprep_clientid %>"
}
variable "clientSecret" {
  type      = string
  sensitive = true
  #default = "<%= customOptions.azurergprep_clientsecret %>"
}

variable "resourceGroup" {
  description = "Resource Group"
  type        = string
  #default     = "terratest"
}

variable "mssqlServerName" {
  description = "MSSQL Server Name"
  type        = string
  validation {
    condition     = length(var.mssqlServerName) > 0 && length(var.mssqlServerName) <= 63
    error_message = "Server name must be greater than 0 and less than or equal to 63 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9]", var.mssqlServerName)) && can(regex("[a-z0-9]$", var.mssqlServerName)) && (!can(regex("[^a-z0-9-]", var.mssqlServerName)))
    error_message = "Server name must contain only lower case letters, hyphens, and numbers. Server name must not start or end with a hypen."
  }
}

/*
variable "mssqlVersion" {
  description = "MSSQL Version"
  type        = string
}
*/
variable "mssqlDBName" {
  description = "MSSQL Database Name"
  type        = string

  validation {
    condition     = length(var.mssqlDBName) > 0 && length(var.mssqlDBName) <= 128
    error_message = "Database name must be less than or equal to 128 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9]", var.mssqlDBName)) && can(regex("[a-zA-Z0-9]$", var.mssqlDBName)) && (!can(regex("[^a-zA-Z0-9-]", var.mssqlDBName)))
    error_message = "Database name must contain only letters, hyphens, and numbers. Database name must not start or end with a hypen."
  }
}

variable "mssqlSKU" {
  description = "MSSQL SKU"
  type        = string
}

variable "minCapacity" {
  type = map(string)
  default = {
    "GP_S_Gen5_1" = "0.5"
    "GP_S_Gen5_2" = "0.5"
    "GP_S_Gen5_4" = "0.5"
    "GP_S_Gen5_6" = "0.75"
    "GP_S_Gen5_8" = "1"
    "GP_S_Gen5_10" = "1.25"
    "GP_S_Gen5_12" = "1.5"
    "GP_S_Gen5_14" = "1.75"
    "GP_S_Gen5_16" = "2"
  }
}

variable "adminUser" {
  description = "Administrator User"
  type        = string

  validation {
    condition     = (!contains(["admin", "administrator", "sa", "root", "dbmanager", "loginmanager", "dbo", "guest", "public"], var.adminUser))
    error_message = "Administrator username must not contain a SQL Identifier or a typical system name."
  }

  validation {
    condition     = can(regex("^[a-z0-9]", var.adminUser)) && can(regex("[a-z0-9]$", var.adminUser)) && (!can(regex("[^a-z0-9-]", var.adminUser)))
    error_message = "Administrator username must contain only lower case letters, hyphens, and numbers. Username must not start or end with a hypen."
  }

}

variable "adminPassword" {
  description = "Administrator Password"
  type        = string

  validation {
    condition     = length(var.adminPassword) >= 8 && length(var.adminPassword) <= 128
    error_message = "Administrator password must be greater than or equal to 8 and less than or equal to 128 characters."
  }

  validation {
    condition     = can(regex("[a-z]", var.adminPassword))
    error_message = "Administrator password must contain at least one lower case letter."
  }

  validation {
    condition     = can(regex("[A-Z]", var.adminPassword))
    error_message = "Administrator password must contain at least one upper case letter."
  }

  validation {
    condition     = can(regex("[0-9]", var.adminPassword))
    error_message = "Administrator password must contain at least one number."
  }

  validation {
    condition     = can(regex("[^a-zA-Z0-9_]", var.adminPassword))
    error_message = "Administrator password must contain at least one special character."
  }

}

# variable "startIPAddress" {
#   description = "Start IP address to allow access to SQL Server."
#   type        = string

#   validation {
#     condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.startIPAddress))
#     error_message = "Invalid start IP address provided."
#   }
# }

# variable "endIPAddress" {
#   description = "End IP address to allow access to SQL Server."
#   type        = string

#   validation {
#     condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.endIPAddress))
#     error_message = "Invalid end IP address provided."
#   }
# }

variable "maxSizeGB" {
  description = "Maximum size of Database(GB)"
  type        = number

  validation {
    condition     = var.maxSizeGB > 0 && var.maxSizeGB <= 1000
    error_message = "The storage size must be greater than 0 and less than or equal to 1000 GB."
  }
}

variable "backupRetentionDays" {
  description = "Backup Retention Days between 7 and 35"
  type        = number

  validation {
    condition     = var.backupRetentionDays >= 7 && var.backupRetentionDays <= 35
    error_message = "Backup retention days must be greater than or equal to 7 and less than or equal to 35 days."
  }
}

variable "vNet" {
  description = "Virtual Network"
  type        = string
}

variable "subnet" {
  description = "Subnet"
  type        = string
}

# variable "resourceGroupOmhsDBA" {
#   description = "Resource Group"
#   type        = string
#   default     = "ocio-omhs-prd-moderate-rg"
# }

# variable "vNetOmhsDBA" {
#   description = "Virtual Network"
#   type        = string
#   default     = "ocio-omhs-prd-moderate-vnet"
# }
# variable "subnetOmhsDBA" {
#   description = "OMHS DBA Subnet"
#   type        = string
#   default     = "ocio-omhs-prd-moderate-app-subnet"
# }
