variable "location" {
  type    = string
  default = "westus"
}

variable "resource_group_name" {
  type = string
}

variable "redis_subnet_id" {
  type        = string
  description = "ID of the subnet to create redis instances in."
}

variable "worker_subnet_id" {
  type        = string
  description = "ID of the subnet to create worker instances in."
}

variable "dns_subdomain" {
  type        = string
  default     = "script-runner"
  description = "Subdomain to prefix to dns_zone_name. API will be served under this subdomain."
}

variable "dns_zone_name" {
  type        = string
  description = "Identifier of the DNS Zone for this instance of script-runner."
}

variable "dns_zone_resource_group_name" {
  type        = string
  description = "Name of the resource group dns_zone_name is in."
}

variable "auth_provider" {
  type        = string
  description = "Auth provider to use for authentication/authorization. Supports 'auth0' and 'none'."
  default     = "auth0"
}

variable "auth0_domain" {
  type        = string
  description = "Domain for Auth0 client used to authenticate users calling script-runner's API. Required if auth_provider is set to 'auth0'."
  default     = ""
}

variable "auth0_audience" {
  type        = string
  description = "Audience for Auth0 client used to authenticate users calling script-runner's API. Required if auth_provider is set to 'auth0'."
  default     = ""
}

variable "auth0_client_id" {
  type        = string
  description = "Identifier for Auth0 client used to authenticate users calling script-runner's API. Required if auth_provider is set to 'auth0'."
  default     = ""
}

variable "stack_name" {
  type        = string
  default     = "script-runner"
  description = "Prefix for names of resources created by terraform."
}

variable "worker_count" {
  type        = number
  default     = 1
  description = "Number of worker container instances to run."
}

variable "server_count" {
  type        = number
  default     = 1
  description = "Number of server container instances to run."
}

variable "image" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "Mapping of environment variables to add to worker containers' environments."
}
