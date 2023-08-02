terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.67.0"
    }
  }
}

provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "rg" {
  name     = "development"
  location = "eastus"
}

resource "azurerm_service_plan" "service-plan" {
  name                = "devPlan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "F1"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "web-app" {
  name                = "development-webapp1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.service-plan.location
  service_plan_id     = azurerm_service_plan.service-plan.id

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = "InstrumentationKey=5dfdb1d1-5d6f-4ffd-8636-212e36b41b73;IngestionEndpoint=https://eastus-8.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus.livediagnostics.monitor.azure.com/"
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "XDT_MicrosoftApplicationInsights_Mode"      = "Recommended"
  }
  client_affinity_enabled = true
  https_only              = true


  site_config {
    always_on  = false
    ftps_state = "FtpsOnly"
    virtual_application {

      physical_path = "site\\wwwroot"
      preload       = false
      virtual_path  = "/"
    }
  }
}

resource "azurerm_application_insights" "dev-insights" {
  name                = "dev-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  sampling_percentage = 0
  workspace_id        = "/subscriptions/5eebd5ca-e3d3-4530-abea-45a3dfd1af8c/resourceGroups/DefaultResourceGroup-EUS/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-5eebd5ca-e3d3-4530-abea-45a3dfd1af8c-EUS"
}

resource "azurerm_postgresql_flexible_server" "flexible-postgre" {
  name                   = "dev-db1997"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "15"
  administrator_login    = "ebruekin"
  administrator_password = "Zm2e8qrzq."
  backup_retention_days  = 7
  // fqdn                          = "dev-db1997.postgres.database.azure.com"
  //id                            = "/subscriptions/5eebd5ca-e3d3-4530-abea-45a3dfd1af8c/resourceGroups/development/providers/Microsoft.DBforPostgreSQL/flexibleServers/dev-db1997"
  //public_network_access_enabled = true
  sku_name   = "B_Standard_B1ms"
  tags       = {}
  zone       = "1"
  storage_mb = 32768

}

resource "azurerm_postgresql_flexible_server_configuration" "example" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.flexible-postgre.id
  value     = "CUBE,CITEXT,BTREE_GIST"
}

resource "azurerm_servicebus_namespace" "service-bus" {
  name                = "dev-serviceB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                                 = "Basic"

}