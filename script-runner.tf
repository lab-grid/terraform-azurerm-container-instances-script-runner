data "azurerm_client_config" "current" {}

# Service definitions

resource "azurerm_container_group" "script_runner" {
  name                = "${var.stack_name}-script-runner-group-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"

  count = var.server_count

  container {
    name  = "${var.stack_name}-script-runner-${count.index}"
    image = "${var.image}:${var.image_tag}"

    commands = [
      "sh",
      "-c",
      "python3 -m gunicorn.app.wsgiapp --timeout 240 --bind 0.0.0.0:$${PORT} --access-logfile - --error-logfile - --workers 4 $${FLASK_APP}",
    ]

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

      "AUTH_PROVIDER"           = var.auth_provider
      "AUTH0_DOMAIN"            = var.auth0_domain
      "AUTH0_CLIENT_ID"         = var.auth0_client_id
      "AUTH0_API_AUTHORITY"     = "https://${var.auth0_domain}/"
      "AUTH0_API_AUDIENCE"      = var.auth0_audience
      "AUTH0_AUTHORIZATION_URL" = "https://${var.auth0_domain}/authorize"
      "AUTH0_TOKEN_URL"         = "https://${var.auth0_domain}/oauth/token"

      "CELERY_BROKER_URL"     = "redis://:${azurerm_redis_cache.celery_broker.primary_access_key}@${azurerm_redis_cache.celery_broker.hostname}:${azurerm_redis_cache.celery_broker.port}"
      "CELERY_RESULT_BACKEND" = "redis://:${azurerm_redis_cache.celery_broker.primary_access_key}@${azurerm_redis_cache.celery_broker.hostname}:${azurerm_redis_cache.celery_broker.port}"
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

  diagnostics {
    log_analytics {
      workspace_id  = azurerm_log_analytics_workspace.script_runner.workspace_id
      workspace_key = azurerm_log_analytics_workspace.script_runner.primary_shared_key
    }
  }

  ip_address_type = "public"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# Load Balancers

resource "azurerm_dns_cname_record" "script_runner_lb" {
  name                = var.dns_subdomain
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
  ttl                 = 60
  record              = "${var.stack_name}-script-runner-lb.azurefd.net"
}

resource "azurerm_frontdoor" "script_runner" {
  name                = "${var.stack_name}-script-runner-lb"
  # location            = "Global"
  # location            = var.location
  resource_group_name = var.resource_group_name

  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "${var.stack_name}-script-runner-rr"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [
      "${var.stack_name}-script-runner-endpoint-1",
      "${var.stack_name}-script-runner-endpoint-2",
    ]
    forwarding_configuration {
      forwarding_protocol = "HttpOnly"
      backend_pool_name   = "${var.stack_name}-script-runner-pool"
    }
  }

  routing_rule {
    name               = "${var.stack_name}-script-runner-rr-http"
    accepted_protocols = ["Http"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [
      "${var.stack_name}-script-runner-endpoint-1",
      "${var.stack_name}-script-runner-endpoint-2",
    ]
    redirect_configuration {
      redirect_protocol = "HttpsOnly"
      redirect_type     = "Found"
    }    
  }

  backend_pool_load_balancing {
    name = "${var.stack_name}-script-runner-lb-settings"
  }

  backend_pool_health_probe {
    name = "${var.stack_name}-script-runner-health-probe"
    path = "/health"
  }

  backend_pool {
    name = "${var.stack_name}-script-runner-pool"

    dynamic "backend" {
      for_each = azurerm_container_group.script_runner
      content {
        host_header = backend.value["ip_address"]
        address     = backend.value["ip_address"]
        http_port   = 80
        https_port  = 443
      }
    }

    load_balancing_name = "${var.stack_name}-script-runner-lb-settings"
    health_probe_name   = "${var.stack_name}-script-runner-health-probe"
  }

  frontend_endpoint {
    name      = "${var.stack_name}-script-runner-endpoint-1"
    host_name = "${var.stack_name}-script-runner-lb.azurefd.net"
  }

  frontend_endpoint {
    name      = "${var.stack_name}-script-runner-endpoint-2"
    host_name = "${var.dns_subdomain}.${var.dns_zone_name}"

    custom_https_provisioning_enabled = true
    custom_https_configuration {
      certificate_source = "FrontDoor"
    }
  }
}
