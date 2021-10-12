provider "digitalocean" {
  token = var.do_token
}

provider "aws" {
  region  = "us-east-1"
}
