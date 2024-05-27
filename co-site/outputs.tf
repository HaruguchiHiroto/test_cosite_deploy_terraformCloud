output "resource_group_name"{
    value = azurerm_resource_group.main.name

}

output "frontDoorEndpointHostName"{
    value = azurerm_cdn_frontdoor_endpoint.cksite_fd.host_name
}

output "swa_api_key"{
    value = azurerm_static_web_app.cksite_web_app.api_key
    sensitive = true
}