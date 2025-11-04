variable "secret_config_file" {
  description = "YAML file describing mounts and secrets"
  type        = string
}

variable "default_mount_type" {
  description = "Default secret engine type (usually kv-v2)"
  type        = string
  default     = "kv-v2"
}

variable "policies_config_file" {
  description = "YAML file describing policies"
  type        = string
}

variable "backend_config_file" {
  description = "YAML file describing auth backends"
  type        = string
}

variable "roles_config_file" {
  description = "YAML file describing auth roles"
  type        = string
}
