resource "azurerm_redis_cache" "celery_broker" {
  name                = "${var.stack_name}-celery-broker"
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"

  # subnet_id                     = var.redis_subnet_id
  public_network_access_enabled = true

  redis_configuration {
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "azurerm_private_endpoint" "celery_broker" {
  name                = "${var.stack_name}-celery-broker-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.redis_subnet_id

  private_service_connection {
    name                           = "${var.stack_name}-celery-broker-psc"
    private_connection_resource_id = azurerm_redis_cache.celery_broker.id

    subresource_names    = [ "redisCache" ]
    is_manual_connection = false
  }
}

# TODO: It's not currently possible to determine the IP address that container instances
#       are making requests from. Thus we must disable the redis cache firewall... :(
resource "azurerm_redis_firewall_rule" "disable" {
  name = "${var.stack_name}"

  redis_cache_name    = azurerm_redis_cache.celery_broker.name
  resource_group_name = var.resource_group_name
  start_ip            = "0.0.0.0"
  end_ip              = "255.255.255.255"
}

# resource "azurerm_redis_firewall_rule" "script_runner" {
#   count = var.server_count

#   name                = replace("${var.stack_name}-script-runner-fw", "-", "_")
#   redis_cache_name    = azurerm_redis_cache.celery_broker.name
#   resource_group_name = var.resource_group_name
#   start_ip            = azurerm_container_group.script_runner[count.index].ip_address
#   end_ip              = azurerm_container_group.script_runner[count.index].ip_address
# }

# resource "azurerm_redis_firewall_rule" "script_worker" {
#   count = var.worker_count

#   name                = replace("${var.stack_name}-script-worker-fw", "-", "_")
#   redis_cache_name    = azurerm_redis_cache.celery_broker.name
#   resource_group_name = var.resource_group_name
#   start_ip            = azurerm_container_group.script_worker[count.index].ip_address
#   end_ip              = azurerm_container_group.script_worker[count.index].ip_address
# }
