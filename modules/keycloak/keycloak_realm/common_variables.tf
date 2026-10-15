variable "realm_conf" {
  description = "Configuration du royaume"
  type = object({
    display_name = optional(string)

    internationalization = optional(object({
      supported_locales = list(string)
      default_locale    = string
    }), null)

    login = optional(object({
      registration_allowed     = bool
      login_with_email_allowed = bool
      remember_me              = bool
      reset_password_allowed   = bool
      duplicate_emails_allowed = bool
      edit_username_allowed    = bool
    }), null)
  })
}

variable "clients" {
  description = "Configuration des clients du royaume"
  type = map(object({
    name = optional(string)

    access_type = string # "PUBLIC" | "CONFIDENTIAL"

    standard_flow_enabled               = optional(bool, true) # authorization code
    service_accounts_enabled            = optional(bool, false)
    pkce_code_challenge_method          = optional(string, null) # "S256" recommandé clients PUBLIC
    implicit_flow_enabled               = optional(bool, false)
    direct_access_grants_enabled        = optional(bool, false)
    oauth2_device_authorization_enabled = optional(bool, false)

    redirect_uris = list(string)
    web_origins   = optional(list(string), [])

    default_scopes  = optional(list(string), ["web-origins", "roles", "profile", "email", "microprofile-jwt"])
    optional_scopes = optional(list(string), [])

    groups_claim      = optional(string, "groups")
    realm_roles_claim = optional(string, "realm-roles")

    add_groups_to = optional(object({
      id_token     = bool
      access_token = bool
      userinfo     = bool
    }), { id_token = true, access_token = true, userinfo = true })

    add_realm_roles_to = optional(object({
      id_token     = bool
      access_token = bool
      userinfo     = bool
    }), { id_token = true, access_token = true, userinfo = true })

    client_roles_mapper = optional(object({
      enabled     = optional(bool, true)
      claim_name  = optional(string, "roles")
      role_prefix = optional(string, null)
      multivalued = optional(bool, true)

      add_to_id_token     = optional(bool, true)
      add_to_access_token = optional(bool, true)
      add_to_userinfo     = optional(bool, true)
    }), null)

    audience_mapper = optional(object({
      enabled                  = optional(bool, true)
      included_client_audience = optional(string, null)

      add_to_id_token     = optional(bool, true)
      add_to_access_token = optional(bool, true)
    }), null)

    roles                 = optional(list(string), [])
    service_account_roles = optional(map(list(string)), {})
  }))

  validation {
    condition     = alltrue([for c in values(var.clients) : contains(["PUBLIC", "CONFIDENTIAL"], c.access_type)])
    error_message = "access_type : PUBLIC ou CONFIDENTIAL."
  }

  validation {
    condition     = alltrue([for c in values(var.clients) : c.service_accounts_enabled || length(c.service_account_roles) == 0])
    error_message = "service_account_roles exige service_accounts_enabled = true."
  }

  validation {
    condition = alltrue(flatten([
      for c in values(var.clients) : [
        for target, roles in c.service_account_roles : [
          for role in roles : contains(try(var.clients[target].roles, []), role)
        ]
      ]
    ]))
    error_message = "service_account_roles : chaque rôle doit être déclaré dans clients[<client>].roles."
  }
}

