variable "clients" {
  type = map(object({
    ip         = string
    public_key = string
  }))
}

variable "do_token" {
  type        = string
  description = "DigitalOcean API token"
}

variable "droplet_image" {
  type        = string
  description = "Image to launch"
  default     = "ubuntu-20-04-x64"
}

variable "droplet_region" {
  type    = string
  description = "Region to launch droplet in"
  default = "nyc3"
}

variable "droplet_size" {
  type        = string
  description = "Size of droplet"
  default     = "s-1vcpu-1gb"
}

variable "server_private_key" {
  type        = string
  description = "Optional private-key to push onto the server"
  default     = ""
}

variable "server_preshared_key" {
  type        = string
  description = "Optional preshared-key to push onto the server"
  default     = ""
}

variable "ssh_root" {
  type        = string
  description = "The path to the SSH keys like ~/.ssh"
  default     = "~/.ssh"
}
variable "ssh_key" {
  type        = string
  description = "The name of the SSH key to use like: id_ed25519.pub"
}
variable "ssh_private_key" {
  type        = string
  description = "The name of the SSH key to use like: id_ed25519"
}

variable "tld_hosted_zone_id" {
  type        = string
  description = "Route53 Hosted zone ID for the wg_tld"
}

variable "wg_tld" {
  type        = string
  description = "Top level domain to use for the wg subdomain"
}

