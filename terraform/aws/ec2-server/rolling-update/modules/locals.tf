locals {
  resource_name = join("-", [var.service_name, var.environment])
}