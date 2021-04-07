resource "azurerm_redis_cache" "celery_broker" {
  name                = "${var.stack_name}-celery-broker"
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = 1
  family              = "P"
  sku_name            = "Premium"

  subnet_id                     = var.redis_subnet_id
  public_network_access_enabled = false

  redis_configuration {
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
