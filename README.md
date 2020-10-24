# Dawg - Wireguard on Digital Ocean 
With a single command, this repo will create a Digital Ocean droplet (server) and configure it as Wireguard server, optionally importing previously created client configs. This means you can destroy and recreate the server and it will come back up without needing to reconfigure your clients.

## Features
* Create a Digital Ocean server configured with Wireguard
* Optionally import existing client configs when the server is created 
* Commands to create new clients and download their configs or import existing configs
* Display downloaded configs as QR codes to easily configure mobile devices (requires `qrencode`)

## Quickstart
1. Download Terraform or asdf
1. Sign up for a Digital Ocean account. Get an API key and write it to `~/.digitalocean/token`. Create an SSH key in Digital Ocean.
1. Sign up with ydns.io. Get an API key and write it to `~/.ydns`
1. Clone this repo locally
1. Edit `terraform/terraform.tfvars`: 
    1. Add your Digital Ocean SSH key ID (you can find this from the DO API)
    1. Set `ydns_url` to whatever your YDNS URL is
    1. Set `clients` to `{}`
1. Run `make deploy`

This will launch a Digital Ocean droplet, apply updates, enable automated security updates, enable the UFW firewall and configure Wireguard. If `clients` in `terraform/terraform.tfvars` is not empty, those clients will be automatically imported into the Wireguard config.

The server's private key is downloaded to `~/.dawg-private-key`. Don't share this with anyone. If this is deleted you'll need to reconfigure all your clients if you destroy and recreate the server.

### Create a new client
Run `make new-client name=<name>` where `<name>` is how you'd like to identify this client (e.g. `laptop`, `phone`, etc). This is only used in strings and can be anything.

The config will be downloaded to `~/Downloads/wg-<name>.conf`. You can then import it into your desktop Wireguard client, or create a QR code with `make qr name=<name>`. 

### Add existing clients
Run `make add-client` and enter the details the help message tells you to.

### Destroy and recreate
If you want to destroy the server, just run `make destroy`. You can recreate it again with `make deploy`.

This uses Terraform - if the `terraform.tfstate` file is deleted, `make destroy` won't work. But this only creates a single Digital Ocean droplet, so in that case just log into your account and manually delete the droplet.

## Other commands
Run `make` for a list of commands that can be run. There are commands to e.g. SSH to the server, check the status, etc.