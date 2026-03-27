output "zone_id" {
  description = "The ID of the Route53 hosted zone"
  value       = local.zone_id
}

output "name_servers" {
  description = "Name servers for the hosted zone (only if created)"
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : []
}

output "record_fqdn" {
  description = "The FQDN of the alias record"
  value       = var.alb_dns_name != "" ? aws_route53_record.alb_alias[0].fqdn : ""
}
