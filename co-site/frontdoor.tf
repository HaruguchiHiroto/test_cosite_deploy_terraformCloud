#local variables
locals{

    front_door_profile_name         = "cksite-pf-fd-${var.env}"
    front_door_endpoint_name        = "cksite-endpoint-${lower(random_id.front_door_endpoint_name.hex)}"
    front_door_origin_group_name    = "cksite-ogrp-fd-${var.env}"
    front_door_origin_name          = "cksite-oname-fd-${var.env}"
    front_door_route_name           = "cksite-roname-fd-${var.env}"
    front_door_ruleset_name         = "CksiteRedirectRuleset"
    front_door_rule_blockauth       = "BlockToAuth"

}

resource "random_id" "front_door_endpoint_name"{
    byte_length = 8
}

#profile
resource "azurerm_cdn_frontdoor_profile" "cksite_fd"{

    name                        = local.front_door_profile_name
    resource_group_name         = azurerm_resource_group.main.name
    sku_name                    = "Standard_AzureFrontDoor"

    response_timeout_seconds    = 120

    tags = {

        senviroment = var.env_tag
        system1 = var.system1_tag
        system2 = var.system2_tag

    }

}

#endpoint
resource "azurerm_cdn_frontdoor_endpoint" "cksite_fd"{

    name                     = local.front_door_endpoint_name
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.cksite_fd.id

}

#originGroup and 
resource "azurerm_cdn_frontdoor_origin_group" "cksite_fd"{

    name                        = local.front_door_origin_group_name
    cdn_frontdoor_profile_id    = azurerm_cdn_frontdoor_profile.cksite_fd.id
    session_affinity_enabled    = false

    load_balancing{

        sample_size                 = 4 
        successful_samples_required = 2

    }

    health_probe{

        path                = "/"
        request_type        = "HEAD"
        protocol            = "Https"
        interval_in_seconds = 120

    }


}

#bloadcast origin
 resource "azurerm_cdn_frontdoor_origin" "cksite_fd"{

    name                            = local.front_door_origin_name
    cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.cksite_fd.id
    enabled                         = true
    host_name                       = azurerm_static_web_app.cksite_web_app.default_host_name
    certificate_name_check_enabled  = false

 }

#route
resource "azurerm_cdn_frontdoor_route" "cksite_fd"{

    name                            = local.front_door_route_name
    cdn_frontdoor_endpoint_id       = azurerm_cdn_frontdoor_endpoint.cksite_fd.id
    cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.cksite_fd.id
    cdn_frontdoor_origin_ids        = [azurerm_cdn_frontdoor_origin.cksite_fd.id]
    cdn_frontdoor_rule_set_ids      = [azurerm_cdn_frontdoor_rule_set.cksite_fd.id]
    enabled                         = true
    supported_protocols             = ["Http","Https"]
    patterns_to_match               = ["/*"]
    forwarding_protocol             = "HttpsOnly"
    link_to_default_domain          = true
    https_redirect_enabled          = true

}

resource "azurerm_cdn_frontdoor_rule_set" "cksite_fd"{

    name                     = local.front_door_ruleset_name
    cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.cksite_fd.id

}

resource "azurerm_cdn_frontdoor_rule" "block_to_access_auth"{

    depends_on                = [azurerm_cdn_frontdoor_origin_group.cksite_fd,azurerm_cdn_frontdoor_origin.cksite_fd]
    name                      = "BlockToAuth"
    cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.cksite_fd.id
    order                     = 1
    behavior_on_match         = "Continue"

    actions{
        route_configuration_override_action {

            cache_behavior = "Disabled"
        
        }

    }

    conditions {
        request_uri_condition{

            operator     = "BeginsWith"
            match_values = ["/.auth"]
        
        }
    }

}

resource "azurerm_cdn_frontdoor_rule" "rule_of_access_to_hoghoge"{

    depends_on                = [azurerm_cdn_frontdoor_origin_group.cksite_fd,azurerm_cdn_frontdoor_origin.cksite_fd]
    name                      = "DefaultRedirect"
    cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.cksite_fd.id
    order                     = 1
    behavior_on_match         = "Continue"

    actions{
        url_redirect_action{
            redirect_type        = "Found"
            destination_hostname = azurerm_static_web_app.cksite_web_app.default_host_name
            redirect_protocol    = "MatchRequest"
            destination_path     = "/hogehoge"
        }
    }

    conditions {
        request_uri_condition{
            operator     = "Contains"
            match_values = ["hogehoge.huga.com"]
        }
    }
}

resource "azurerm_cdn_frontdoor_rule" "rule_of_access_to_article"{

    depends_on                = [azurerm_cdn_frontdoor_origin_group.cksite_fd,azurerm_cdn_frontdoor_origin.cksite_fd]
    name                      = "ArticleRedirect"
    cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.cksite_fd.id
    order                     = 1
    behavior_on_match         = "Continue"

    actions{
        url_redirect_action{
            redirect_type        = "Found"
            destination_hostname = azurerm_static_web_app.cksite_web_app.default_host_name 
            redirect_protocol    = "MatchRequest"
            destination_path     = "/{url_path:-11}"
        }
    }

    conditions {
        request_uri_condition{
            operator     = "RegEx"
            match_values = ["${azurerm_static_web_app.cksite_web_app.default_host_name}/media/news/[0-9]{10}/"]
        }
    }
}
