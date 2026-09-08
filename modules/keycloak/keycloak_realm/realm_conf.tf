
locals {
  intl = var.realm_conf.internationalization
}

resource "keycloak_realm" "realm" {

  realm = replace(coalesce(var.realm_conf.display_name, "default"), " ", "-")

  display_name = var.realm_conf.display_name

  dynamic "internationalization" {
    for_each = local.intl == null ? [] : [var.realm_conf.internationalization]

    content {
      supported_locales = internationalization.value.supported_locales
      default_locale    = internationalization.value.default_locale
    }
  }

  registration_allowed     = var.realm_conf.login == null ? false : var.realm_conf.login.registration_allowed
  login_with_email_allowed = var.realm_conf.login == null ? false : var.realm_conf.login.login_with_email_allowed
  remember_me              = var.realm_conf.login == null ? false : var.realm_conf.login.remember_me
  reset_password_allowed   = var.realm_conf.login == null ? false : var.realm_conf.login.reset_password_allowed
  duplicate_emails_allowed = var.realm_conf.login == null ? false : var.realm_conf.login.duplicate_emails_allowed
  edit_username_allowed    = var.realm_conf.login == null ? false : var.realm_conf.login.edit_username_allowed
}

