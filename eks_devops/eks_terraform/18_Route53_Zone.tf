module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = {
    "${var.domain_name}" = {
      comment = "${var.domain_name} (production)"
      tags = {
        env = "production"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
  #   depends_on = [module.TODO] if any
}


module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain_name
  zone_id     = values(module.zones.route53_zone_zone_id)[0]

  validation_method = "DNS"

  wait_for_validation    = false
  create_route53_records = true

  tags = {
    Name      = var.domain_name
    ManagedBy = "Terraform"
  }
  depends_on = [module.zones]
}