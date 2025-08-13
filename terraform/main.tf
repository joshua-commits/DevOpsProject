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



# ------------------------------------------------------------
# Azure Container Registry
# ------------------------------------------------------------


resource "azurerm_container_registry" "acr" {
  name                = "acr${var.environment}kdb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
  
}

# ------------------------------------------------------------
# User Assigned Managed Identity
# ------------------------------------------------------------

resource "azurerm_user_assigned_identity" "identity" {
  name                = "identity-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}


# ------------------------------------------------------------
# Grant the identity AcrPull on the ACR
# ------------------------------------------------------------

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}




# Automate docker image import from Docker Hub to ACR
resource "null_resource" "import_image" {
  depends_on = [azurerm_container_registry.acr]

  provisioner "local-exec" {
    command = <<EOT
  az acr import --name ${azurerm_container_registry.acr.name} --source docker.io/${var.image_repo}:${var.image_tag} --image ${var.image_repo}:${var.image_tag}
  EOT
  }
}





# ------------------------------------------------------------
# Azure Web App Service Plan
# ------------------------------------------------------------
resource "azurerm_service_plan" "plan" {
  name                = "plan-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1" 
}



# ------------------------------------------------------------
# Azure Web App
# ------------------------------------------------------------

  resource "azurerm_linux_web_app" "webapp" {
  name                = "webapp-${var.environment}-kdb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  # Attach the User Assigned Managed Identity
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }

  site_config {
    application_stack {
      # Build the image name from registry + repo + tag
      docker_image_name = "${trim(azurerm_container_registry.acr.login_server, "/")}/${var.image_repo}:${var.image_tag}"
    }

    always_on = false
  }

  app_settings = {
    "DOCKER_ENABLE_CI"                  = "true"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "WEBSITES_PORT" = "5000"
  }
  depends_on = [
    null_resource.import_image, # Ensures image is in ACR before deploy
    azurerm_role_assignment.acr_pull
  ]
}


 
