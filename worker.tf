# Service definitions

resource "azurerm_network_profile" "script_worker" {
  name                = "${var.stack_name}-script-worker-netprofile"
  location            = var.location
  resource_group_name = var.resource_group_name

  container_network_interface {
    name = "${var.stack_name}-script-worker-netinterface"
    ip_configuration {
      name      = "${var.stack_name}-script-worker-ipconfig"
      subnet_id = var.worker_subnet_id
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "azurerm_container_group" "script_worker" {
  name                = "${var.stack_name}-script-worker-group-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"

  count = var.worker_count

  container {
    name  = "${var.stack_name}-script-worker-${count.index}"
    image = "${var.image}:${var.image_tag}"

    commands = [
      "sh",
      "-c",
      "python3 -m celery -A script_runner.analysis worker --concurrency=1",
    ]

    cpu    = 4
    memory = 16

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      "CELERY_BROKER_URL"     = "rediss://:${azurerm_redis_cache.celery_broker.primary_access_key}@${azurerm_private_endpoint.celery_broker.private_service_connection[0].private_ip_address}:${azurerm_redis_cache.celery_broker.ssl_port}?ssl_cert_reqs=required"
      "CELERY_RESULT_BACKEND" = "rediss://:${azurerm_redis_cache.celery_broker.primary_access_key}@${azurerm_private_endpoint.celery_broker.private_service_connection[0].private_ip_address}:${azurerm_redis_cache.celery_broker.ssl_port}?ssl_cert_reqs=required"
    }

    secure_environment_variables = var.environment_variables

    readiness_probe {
      exec                  = ["exit", "0"]
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

  ip_address_type    = "private"
  network_profile_id = azurerm_network_profile.script_worker.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
