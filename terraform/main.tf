resource "digitalocean_ssh_key" "wg" {
  name       = "WG-Access"
  public_key = file(format("%s/%s", "${var.ssh_root}", "${var.ssh_key}"))
}

resource "digitalocean_droplet" "wg" {
  image     = var.droplet_image
  name      = "wg"
  region    = var.droplet_region
  size      = var.droplet_size
  ssh_keys  = [digitalocean_ssh_key.wg.fingerprint]
  user_data = templatefile("${path.module}/templates/user-data.txt", {
    server_private_key   = var.server_private_key
    server_preshared_key = var.server_preshared_key
    wg_configure_server  = base64encode(file("${path.module}/templates/wg-configure-server.sh"))
    wg_add_client        = base64encode(file("${path.module}/templates/wg-add-client.sh"))
  })
}

# resource "digitalocean_firewall" "web" {
#   name = "only-22-51820-in-all-out"

#   droplet_ids = [digitalocean_droplet.wg.id]

#   inbound_rule {
#     protocol         = "tcp"
#     port_range       = "22"
#     source_addresses = ["0.0.0.0/0", "::/0"]
#   }

#   inbound_rule {
#     protocol         = "udp"
#     port_range       = "51820"
#     source_addresses = ["0.0.0.0/0", "::/0"]
#   }

#   outbound_rule {
#     protocol              = "tcp"
#     port_range            = "1-65535"
#     destination_addresses = ["0.0.0.0/0", "::/0"]
#   }

#   outbound_rule {
#     protocol              = "udp"
#     port_range            = "51820"
#     destination_addresses = ["0.0.0.0/0", "::/0"]
#   }

#   outbound_rule {
#     protocol              = "icmp"
#     destination_addresses = ["0.0.0.0/0", "::/0"]
#   }
# }

resource "null_resource" "accept_ssh_key" {
  provisioner "local-exec" {
    command = <<EOF
set -x
while :
do
  ssh-keygen -R ${digitalocean_droplet.wg.ipv4_address}
  ssh-keyscan -H ${digitalocean_droplet.wg.ipv4_address} >> ~/.ssh/known_hosts
  if [ $? -ne 0 ]; then
    echo "SSH keys not ready, sleeping"
    sleep 5
  else
    break
  fi
done
EOF
  }
}

resource "null_resource" "server_ready" {
  depends_on = [null_resource.accept_ssh_key]

  provisioner "local-exec" {
    command = <<EOF
set -x
cd ..
while :
do
  make status ip=${digitalocean_droplet.wg.ipv4_address}
  if [ $? -ne 0 ]; then
    echo "Server not ready, sleeping"
    sleep 10
  else
    sleep 30      # let the server restart
    break
  fi
done
EOF
  }
}

resource "aws_route53_record" "route53_entry_wg" {
  zone_id         = "${var.tld_hosted_zone_id}"
  name            = "wireguard"
  type            = "CNAME"
  ttl             = "5"

  # weighted_routing_policy {
  #   weight = 100
  # }
  records         = [ "${digitalocean_droplet.wg.ipv4_address}" ]
  # set_identifier  = "wg"
}


module "clients" {
  source     = "./modules/client"
  # depends_on = [null_resource.server_ready]

  ssh_root        = var.ssh_root
  ssh_private_key = var.ssh_private_key
  for_each        = var.clients
  ip              = each.value.ip
  name            = each.key
  public_key      = each.value.public_key
  server_ip       = digitalocean_droplet.wg.ipv4_address
}
