# Service definitions

resource "azurerm_network_profile" "script_runner" {
  name                = "${var.stack_name}-script-runner-netprofile"
  location            = var.location
  resource_group_name = var.resource_group_name

  container_network_interface {
    name = "${var.stack_name}-script-runner-netinterface"
    ip_configuration {
      name      = "${var.stack_name}-script-runner-ipconfig"
      subnet_id = var.server_subnet_id
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "azurerm_container_group" "script_runner" {
  name                = "${var.stack_name}-script-runner-group-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  count = var.server_count

  container {
    name  = "${var.stack_name}-script-runner-${count.index}"
    image = "${var.image}:${var.image_tag}"

    cpu    = 1
    memory = 1

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      "PORT"                 = "80"
      "FLASK_ENV"            = "production"
      "PROPAGATE_EXCEPTIONS" = "False"

      "AUTH_PROVIDER"           = var.auth_type
      "AUTH0_DOMAIN"            = var.auth0_domain
      "AUTH0_CLIENT_ID"         = var.auth0_client_id
      "AUTH0_API_AUTHORITY"     = "https://${var.auth0_domain}/"
      "AUTH0_API_AUDIENCE"      = var.auth0_audience
      "AUTH0_AUTHORIZATION_URL" = "https://${var.auth0_domain}/authorize"
      "AUTH0_TOKEN_URL"         = "https://${var.auth0_domain}/oauth/token"

      "CELERY_BROKER_URL"     = azurerm_redis_cache.celery_broker.primary_connection_string
      "CELERY_RESULT_BACKEND" = azurerm_redis_cache.celery_broker.primary_connection_string
    }

    liveness_probe {
      http_get {
        path   = "/health"
        port   = 80
        scheme = "Http"
      }
      initial_delay_seconds = 5
      period_seconds        = 30
    }

    readiness_probe {
      http_get {
        path   = "/health"
        port   = 80
        scheme = "Http"
      }
      initial_delay_seconds = 5
      period_seconds        = 30
    }
  }

  ip_address_type = "private"

  network_profile_id = azurerm_network_profile.script_runner.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# DNS/SSL

resource "azurerm_app_service_certificate_order" "script_runner" {
  name                = "${var.stack_name}-script-runner-cert-order"
  resource_group_name = var.resource_group_name
  location            = "global"
  distinguished_name  = "CN=${var.dns_subdomain}.${var.dns_domain}"
  product_type        = "Standard"
}

resource "azurerm_dns_cname_record" "script_runner_www" {
  name                = "www.${var.dns_subdomain}"
  zone_name           = var.dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 60
  record              = "${var.dns_subdomain}.${var.dns_domain}"
}

resource "azurerm_dns_txt_record" "script_runner_validation" {
  name                = "asuid.www.${var.dns_subdomain}"
  zone_name           = var.dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 60

  record {
    value = azurerm_app_service_certificate_order.script_runner.domain_verification_token
  }
}

resource "azurerm_dns_a_record" "script_runner_lb" {
  name                = var.dns_subdomain
  zone_name           = var.dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 60
  records = [
    azurerm_public_ip.load_balancer.ip_address
  ]
}


# Load Balancers

resource "azurerm_public_ip" "load_balancer" {
  name                = "${var.stack_name}-script-runner-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_lb_backend_address_pool" "load_balancer" {
  loadbalancer_id = azurerm_lb.load_balancer.id
  name            = "${var.stack_name}-script-runner-pool"
}

resource "azurerm_lb_backend_address_pool_address" "script_runner" {
  name                    = "${var.stack_name}-script-runner-addr"
  backend_address_pool_id = azurerm_lb_backend_address_pool.load_balancer.id
  virtual_network_id      = azurerm_virtual_network.load_balancer.id
  ip_address              = azurerm_container_group.script_runner.ip_address
}

resource "azurerm_application_gateway" "load_balancer" {
  name                = "${var.stack_name}-script-runner-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name = "Standard_Small"
    tier = "Standard"
  }

  autoscale_configuration {
    min_capacity = 0
    max_capacity = 4
  }

  gateway_ip_configuration {
    name      = "${var.stack_name}-script-runner-agw-ipconf"
    subnet_id = var.server_subnet_id
  }

  frontend_port {
    name = "${var.stack_name}-script-runner-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.stack_name}-script-runner-ip-conf"
    public_ip_address_id = azurerm_public_ip.load_balancer.id
  }

  backend_address_pool {
    name = azurerm_lb_backend_address_pool.load_balancer.name
  }

  backend_http_settings {
    name                  = "${var.stack_name}-script-runner-httpconf"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "${var.stack_name}-script-runner-listener"
    frontend_ip_configuration_name = "${var.stack_name}-script-runner-ip-conf"
    frontend_port_name             = "${var.stack_name}-script-runner-port"
    protocol                       = "Https"

    ssl_certificate_name = azurerm_app_service_certificate_order.script_runner.certificates.certificate_name
  }

  request_routing_rule {
    name                       = "${var.stack_name}-script-runner-listener-rule"
    rule_type                  = "Basic"
    http_listener_name         = "${var.stack_name}-script-runner-listener"
    backend_address_pool_name  = azurerm_lb_backend_address_pool.load_balancer.name
    backend_http_settings_name = "${var.stack_name}-script-runner-httpconf"
  }
}
