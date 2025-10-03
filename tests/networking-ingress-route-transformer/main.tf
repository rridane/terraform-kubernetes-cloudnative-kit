module "route-transformer" {
  source = "../../modules/networking-ingress-route-transformer"
  yaml_file = "${path.cwd}/fixtures/routes.yaml"
}

output "routes" {
  value = module.route-transformer.routes
}

