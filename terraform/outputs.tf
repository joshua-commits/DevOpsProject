output "webapp_url" {
    value = azurerm_linux_web_app.webapp.default_hostname
    description = "The URL of the webapp"   
}

output "resource_group_name" {
    value = azurerm_resource_group.rg.name
    description = "The name of the resource group"
}

output "service_plan_name" {
    value = azurerm_service_plan.plan.name
    description = "The name of the service plan"
}

output "webapp_name" {
    value = azurerm_linux_web_app.webapp.name
    description = "The name of the webapp"
}

output "acr_name" {
    value = azurerm_container_registry.acr.name
    description = "The name of the ACR"
}

output "acr_login_server" {
    value = azurerm_container_registry.acr.login_server
    description = "The login server of the ACR"
}