variable "secret_config_file" {
  description = "YAML file describing mounts and secrets. Ignored when secret_config_dir is set"
  type        = string
  default     = null
}

variable "secret_config_dir" {
  description = "Directory of YAML files describing mounts and secrets, merged by mount"
  type        = string
  default     = null
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
