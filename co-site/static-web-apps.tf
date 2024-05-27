resource "random_id" "app_name"{
    byte_length = 8
}

resource "azurerm_static_web_app" "cksite_web_app"{
    name                = "cksite-webapp-${var.env}"
    resource_group_name = azurerm_resource_group.main.name
    location            = "East Asia"
    sku_tier            = "Standard"
    sku_size            = "Standard"

    tags = {

        senviroment = var.env_tag
        system1 = var.system1_tag
        system2 = var.system2_tag

    }

}