terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc9"
    }

    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }

    time = {
      source = "hashicorp/time"
      version = "0.13.1"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.PROXMOX_URL
  pm_tls_insecure = true
  pm_api_token_id = var.PROXMOX_TOKEN_ID
  pm_api_token_secret = var.PROXMOX_TOKEN_SECRET
}
