# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "24498a08-ef32-4d96-bf00-a59364945b9b"
}

# 1. Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.environment}"
  location = var.location
}

# 2. Create a service plan
resource "azurerm_service_plan" "plan" {
  name                = "plan-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1" 
}

# # 3. azure container registry
# resource "azurerm_container_registry" "acr" {
#   name                = "acr-${var.environment}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   sku                 = "Basic"
#   admin_enabled       = true
#   admin_password      = "password"
#   admin_username      = "admin"
#   login_server        = "login-server"
# }

# 4. webapp
resource "azurerm_linux_web_app" "webapp" {
  name                = "webapp-${var.environment}-kdb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id
  
  site_config {
    application_stack {
      docker_image_name = "joshuacreates/hello-tested-api:latest"
      docker_registry_url = "https://index.docker.io"
      docker_registry_username = var.docker_username
      docker_registry_password = var.docker_password
    }
      

      always_on = false
  }

  app_settings = {
  "DOCKER_ENABLE_CI"                = "true"
}


}
