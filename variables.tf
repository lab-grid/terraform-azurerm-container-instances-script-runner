variable "region" {
  type    = string
  default = "us-west-1"
}

variable "location" {
  type    = string
  default = "california"
}

variable "resource_group_name" {
  type = string
}

variable "redis_subnet_id" {
  type = string
}

variable "server_subnet_id" {
  type = string
}

variable "worker_subnet_id" {
  type = string
}

variable "network_profile_id" {
  type = string
}

variable "dns_subdomain" {
  type = string
}

variable "dns_domain" {
  type        = string
  description = "DNS name for this instance of script-runner. Must match 'dns_zone_id'."
}

variable "dns_zone_name" {
  type        = string
  description = "Identifier of the Route53 Hosted Zone for this instance of script-runner."
}

variable "auth_type" {
  type        = string
  description = "Auth type for API."
  default     = "none"
}

variable "auth0_domain" {
  type        = string
  description = "Domain for Auth0 client used to authenticate users calling script-runner's API."
  default     = ""
}

variable "auth0_audience" {
  type        = string
  description = "Audience for Auth0 client used to authenticate users calling script-runner's API."
  default     = ""
}

variable "auth0_client_id" {
  type        = string
  description = "Identifier for Auth0 client used to authenticate users calling script-runner's API."
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
