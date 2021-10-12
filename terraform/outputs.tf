output "ip" {
  value = digitalocean_droplet.wg.ipv4_address
}

# output "endpoint" {
#   value = aws_route53_record.route53_entry_wg.fqdn
# }
