locals {
  port = 5432

  hosts = [
    format("%s%s.%s.svc.%s", local.name, (local.architecture == "replication" ? "-primary" : ""), local.namespace, local.domain_suffix)
  ]
  hosts_readonly = local.architecture == "replication" ? [
    format("%s-secondary.%s.svc.%s", local.name, local.namespace, local.domain_suffix)
  ] : []

  endpoints = [
    for c in local.hosts : format("%s:%d", c, local.port)
  ]
  endpoints_readonly = [
    for c in(local.hosts_readonly != null ? local.hosts_readonly : []) : format("%s:%d", c, local.port)
  ]
}

#
# Orchestration
#

output "context" {
  description = "The input context, a map, which is used for orchestration."
  value       = var.context
}

output "refer" {
  description = "The refer, a map, including hosts, ports and account, which is used for dependencies or collaborations."
  sensitive   = true
  value = {
    schema = "k8s:postgresql"
    params = {
      selector           = local.labels
      hosts              = local.hosts
      hosts_readonly     = local.hosts_readonly
      port               = local.port
      endpoints          = local.endpoints
      endpoints_readonly = local.endpoints_readonly
      database           = local.database
      username           = local.username
      password           = nonsensitive(local.password)
    }
  }
}

#
# Reference
#

output "connection" {
  description = "The connection, a string combined host and port, might be a comma separated string or a single string."
  value       = join(",", local.endpoints)
}

output "connection_readonly" {
  description = "The readonly connection, a string combined host and port, might be a comma separated string or a single string."
  value       = join(",", local.endpoints_readonly)
}

output "address" {
  description = "The address, a string only has host, might be a comma separated string or a single string."
  value       = join(",", local.hosts)
}

output "address_readonly" {
  description = "The readonly address, a string only has host, might be a comma separated string or a single string."
  value       = join(",", local.hosts_readonly)
}

output "port" {
  description = "The port of the service."
  value       = local.port
}

output "database" {
  description = "The name of PostgreSQL database to access."
  value       = local.database
}

output "username" {
  description = "The username of the account to access the database."
  value       = local.username
}

output "password" {
  value       = local.password
  description = "The password of the account to access the database."
  sensitive   = true
}
