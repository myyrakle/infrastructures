locals{
  queue_name = join("_", [var.service_name, "queue", var.environment])
  lambda_name = join("-", [var.service_name, var.environment])
}