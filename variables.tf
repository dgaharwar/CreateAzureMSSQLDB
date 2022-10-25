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

variable "mysqlServerName" {
  description = "MySQL Server Name"
  type        = string

  validation {
    condition     = length(var.mysqlServerName) >= 3 && length(var.mysqlServerName) <= 63
    error_message = "Server name must be >= 3 and <= 63 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9]", var.mysqlServerName)) && can(regex("[a-z0-9]$", var.mysqlServerName)) && (!can(regex("[^a-z0-9-]", var.mysqlServerName)))
    error_message = "Server name must contain only lower case letters, hyphens, and numbers. Server name must not start or end with a hypen."
  }
}

variable "mysqlVersion" {
  description = "MySQL Version"
  type        = string
}

variable "mysqlServerSKU" {
  description = "MySQL Server SKU"
  type        = string
}

variable "adminUser" {
  description = "Administrator User"
  type        = string

  validation {
    condition     = length(var.adminUser) >= 1 && length(var.adminUser) <= 16
    error_message = "Administrator username must be >= 1 and <= 63 characters."
  }

  validation {
    condition     = (!contains(["azure_superuser", "admin", "administrator", "root", "guest", "public"], var.adminUser))
    error_message = "Administrator username cannot be entered value."
  }

  validation {
    condition     = can(regex("^[a-zA-Z]", var.adminUser)) && can(regex("[a-zA-Z0-9]$", var.adminUser)) && (!can(regex("[^a-zA-Z0-9]", var.adminUser)))
    error_message = "Administrator username must contain only alphanumeric characters and must not start with a number."
  }

}

variable "adminPassword" {
  description = "Administrator Password"
  type        = string

  validation {
    condition     = length(var.adminPassword) >= 8 && length(var.adminPassword) <= 128
    error_message = "Administrator password must be >= 8 and <= 128 characters."
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

variable "storageSizeGB" {
  description = "Storage size (GB)"
  type        = number

  validation {
    condition     = var.storageSizeGB >= 5 && var.storageSizeGB <= 16000
    error_message = "The storage size must be >= 5 and <= 16000 GB."
  }
}

variable "mysqlDBName" {
  description = "MySQL Database Name"
  type        = string

  validation {
    condition     = length(var.mysqlDBName) > 0 && length(var.mysqlDBName) <= 128
    error_message = "Database name must be <= 128 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9]", var.mysqlDBName)) && can(regex("[a-zA-Z0-9]$", var.mysqlDBName)) && (!can(regex("[^a-zA-Z0-9-_]", var.mysqlDBName)))
    error_message = "Database name must contain only letters, hyphens, and numbers. Database name must not start or end with a hypen."
  }
}

variable "charset" {
  description = "Charset for the MySQL Database"
  type        = string
}

variable "collation" {
  description = "Collation for the MySQL Database"
  type        = string
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

variable "backupRetentionDays" {
  description = "Backup Retention Days between 7 and 35"
  type        = number

  validation {
    condition     = var.backupRetentionDays >= 7 && var.backupRetentionDays <= 35
    error_message = "Backup retention days must be >= 7 and <= 35 days."
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

variable "enableGeoRedundateBackup" {
  description = "Enable Geo Redundant Backup"
  type        = bool
  default     = true
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
