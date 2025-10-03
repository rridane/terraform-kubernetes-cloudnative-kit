package sites

sites := [{"name": "prod"}, {"name": "smoke1"}, {"name": "dev"}]

prod_exists if {
    some site in sites
    site.name == "prod"
}

deny contains msg if {
  prod_exists == true
  msg := "Containers must not run as root"
}

allow contains msg if {
  prod_exists == true
  msg := "Containers must not run as root"
}

