
locals {
  policies_content = yamldecode(file(var.policies_config_file))
  backends_content = yamldecode(file(var.backend_config_file))
  roles_content = yamldecode(file(var.roles_config_file))
  policies_list    = local.policies_content["capabilities"]
  backends_list    = local.backends_content["backends"]
  roles_list = local.roles_content["roles"]

  kubernetes_backend = local.backends_list["kubernetes"]
  app_role_backend = local.backends_list["app_role"]
  oidc_backend = local.backends_list["oidc"]

}

