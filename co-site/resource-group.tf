#resource group
resource "azurerm_resource_group" "main"{

    name     = "cksite-rg-${var.env}"
    location = "Japan East"

    tags = {

        system1 = var.system1_tag
        system2 = var.system2_tag

    }
}