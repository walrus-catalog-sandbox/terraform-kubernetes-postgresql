#
# Contextual Fields
#

variable "context" {
  description = <<-EOF
Receive contextual information. When Walrus deploys, Walrus will inject specific contextual information into this field.

Examples:
```
context:
  project:
    name: string
    id: string
  environment:
    name: string
    id: string
  resource:
    name: string
    id: string
```
EOF
  type        = map(any)
  default     = {}
}

#
# Infrastructure Fields
#

variable "infrastructure" {
  description = <<-EOF
Specify the infrastructure information for deploying.

Examples:
```
infrastructure:
  namespace: string, optional
  image_registry: string, optional
  domain_suffix: string, optional
  service_type: string, optional
```
EOF
  type = object({
    namespace      = optional(string)
    image_registry = optional(string, "registry-1.docker.io")
    domain_suffix  = optional(string, "cluster.local")
    service_type   = optional(string, "ClusterIP")
  })
  default = {}
}

#
# Deployment Fields
#

variable "architecture" {
  description = <<-EOF
Specify the deployment architecture, select from standalone or replication.
EOF
  type        = string
  default     = "standalone"
  validation {
    condition     = var.architecture == "" || contains(["standalone", "replication"], var.architecture)
    error_message = "Invalid architecture"
  }
}

variable "replication_readonly_replicas" {
  description = <<-EOF
Specify the number of read-only replicas under the replication deployment.
EOF
  type        = number
  default     = 1
  validation {
    condition     = var.replication_readonly_replicas == 0 || contains([1, 3, 5], var.replication_readonly_replicas)
    error_message = "Invalid number of read-only replicas"
  }
}

variable "engine_version" {
  description = <<-EOF
Specify the deployment engine version, select from https://hub.docker.com/r/bitnami/postgresql/tags.
EOF
  type        = string
  default     = "16.0"
}

variable "database" {
  description = <<-EOF
Specify the database name. The database name must be 2-64 characters long and start with any lower letter, combined with number, or symbols: - _.
The database name cannot be PostgreSQL forbidden keyword.
EOF
  type        = string
  default     = "mydb"
  validation {
    condition     = var.database == "" || can(regex("^[a-z][-a-z0-9_]{0,61}[a-z0-9]$", var.database))
    error_message = format("Invalid database: %s", var.database)
  }
}

variable "username" {
  description = <<-EOF
Specify the account username. The username must be 2-16 characters long and start with lower letter, combined with number, or symbol: _.
The username cannot be PostgreSQL forbidden keyword.
EOF
  type        = string
  default     = "rdsuser"
  validation {
    condition     = var.username == "" || can(regex("^[a-z][a-z0-9_]{0,14}[a-z0-9]$", var.username))
    error_message = format("Invalid username: %s", var.username)
  }
}

variable "password" {
  description = <<-EOF
Specify the account password. The password must be 8-32 characters long and start with any letter, number, or symbols: ! # $ % ^ & * ( ) _ + - =.
If not specified, it will generate a random password.
EOF
  type        = string
  default     = null
  sensitive   = true
  validation {
    condition     = var.password == null || var.password == "" || can(regex("^[A-Za-z0-9\\!#\\$%\\^&\\*\\(\\)_\\+\\-=]{8,32}", var.password))
    error_message = "Invalid password"
  }
}

variable "resources" {
  description = <<-EOF
Specify the computing resources.

Examples:
```
resources:
  cpu: number, optional
  memory: number, optional       # in megabyte
```
EOF
  type = object({
    cpu    = optional(number, 0.25)
    memory = optional(number, 512)
  })
  default = {
    cpu    = 0.25
    memory = 512
  }
}

variable "storage" {
  description = <<-EOF
Specify the storage resources.

Examples:
```
storage:                         # convert to empty_dir volume or dynamic volume claim template
  class: string, optional
  size: number, optional         # in megabyte
```
EOF
  type = object({
    class = optional(string)
    size  = optional(number, 10 * 1024)
  })
  default = null
}

#
# Seeding Fields
#

variable "seeding" {
  description = <<-EOF
Specify the configuration to seed the database at first-time creating.

Seeding increases the startup time waiting and also needs proper permission, 
like root account.

Examples:
```
seeding:
  type: none/url/text
  url:                           # store the content to a volume
    location: string
    storage:                     # convert to dynamic volume claim template
      class: string, optional
      size: number, optional     # in megabyte
  text:                          # store the content to a configmap
    content: string
```
EOF
  type = object({
    type = optional(string, "none")
    url = optional(object({
      location = string
      storage = optional(object({
        class = optional(string)
        size  = optional(number, 10 * 1024)
      }))
    }))
    text = optional(object({
      content = string
    }))
  })
  default = {}
  validation {
    condition     = var.seeding.type == null || contains(["none", "url", "text"], var.seeding.type)
    error_message = "Invalid type"
  }
}
