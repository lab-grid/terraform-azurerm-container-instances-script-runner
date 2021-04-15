# terraform-azurerm-container-instances-script-runner

This module deploys the script-runner server/worker as an Azure Container Instances service.

## Requirements

* A valid Azure account
* A published docker container with both `script-runner` and your script of choice installed
* An Azure DNS zone to add records for a script-runner subdomain to

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_certificate_order.script_runner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_certificate_order) | resource |
| [azurerm_application_gateway.load_balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_container_group.script_runner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) | resource |
| [azurerm_container_group.script_worker](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) | resource |
| [azurerm_dns_a_record.script_runner_lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_dns_cname_record.script_runner_www](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record) | resource |
| [azurerm_dns_txt_record.script_runner_validation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_txt_record) | resource |
| [azurerm_lb_backend_address_pool.load_balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_backend_address_pool_address.script_runner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool_address) | resource |
| [azurerm_network_profile.script_runner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_profile) | resource |
| [azurerm_public_ip.load_balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_redis_cache.celery_broker](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth0_audience"></a> [auth0\_audience](#input\_auth0\_audience) | Audience for Auth0 client used to authenticate users calling script-runner's API. Required if auth\_provider is set to 'auth0'. | `string` | `""` | no |
| <a name="input_auth0_client_id"></a> [auth0\_client\_id](#input\_auth0\_client\_id) | Identifier for Auth0 client used to authenticate users calling script-runner's API. Required if auth\_provider is set to 'auth0'. | `string` | `""` | no |
| <a name="input_auth0_domain"></a> [auth0\_domain](#input\_auth0\_domain) | Domain for Auth0 client used to authenticate users calling script-runner's API. Required if auth\_provider is set to 'auth0'. | `string` | `""` | no |
| <a name="input_auth_provider"></a> [auth\_provider](#input\_auth\_provider) | Auth provider to use for authentication/authorization. Supports 'auth0' and 'none'. | `string` | `"auth0"` | no |
| <a name="input_dns_subdomain"></a> [dns\_subdomain](#input\_dns\_subdomain) | Subdomain to prefix to dns\_zone\_name. API will be served under this subdomain. | `string` | `"script-runner"` | no |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | Identifier of the DNS Zone for this instance of script-runner. | `string` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Mapping of environment variables to add to worker containers' environments. | `map(string)` | `{}` | no |
| <a name="input_image"></a> [image](#input\_image) | n/a | `string` | n/a | yes |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | n/a | `string` | `"latest"` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"westus"` | no |
| <a name="input_redis_subnet_id"></a> [redis\_subnet\_id](#input\_redis\_subnet\_id) | ID of the subnet to create redis instances in. | `string` | `"redis-subnet"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_server_count"></a> [server\_count](#input\_server\_count) | Number of server container instances to run. | `number` | `1` | no |
| <a name="input_server_subnet_id"></a> [server\_subnet\_id](#input\_server\_subnet\_id) | ID of the subnet to create server instances in. | `string` | `"server-subnet"` | no |
| <a name="input_stack_name"></a> [stack\_name](#input\_stack\_name) | Prefix for names of resources created by terraform. | `string` | `"script-runner"` | no |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | Number of worker container instances to run. | `number` | `1` | no |
| <a name="input_worker_subnet_id"></a> [worker\_subnet\_id](#input\_worker\_subnet\_id) | ID of the subnet to create worker instances in. | `string` | `"worker-subnet"` | no |

## Outputs

No outputs.
