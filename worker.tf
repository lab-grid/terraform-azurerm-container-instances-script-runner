# Service definitions

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
      "python3",
      "-m",
      "celery",
      "-A",
      "analysis",
      "worker",
      "--concurrency=1"
    ]

    cpu    = 4
    memory = 20

    environment_variables = {
      "CELERY_BROKER_URL"     = azurerm_redis_cache.celery_broker.primary_connection_string
      "CELERY_RESULT_BACKEND" = azurerm_redis_cache.celery_broker.primary_connection_string
    }

    secure_environment_variables = var.environment_variables

    readiness_probe {
      exec                  = ["exit", "0"]
      initial_delay_seconds = 5
      period_seconds        = 30
    }
  }

  ip_address_type = "private"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
