module "builtin_compute" {
  source = "./modules/policy"
  policy_directory = "${path.module}/builtin-policies/compute"
}

module "builtin_general" {
  source = "./modules/policy"
  policy_directory = "${path.module}/builtin-policies/general"
}

module "custom_network" {
    source = "./modules/policy"
    policy_directory = "${path.module}/custom-policies/network"
}