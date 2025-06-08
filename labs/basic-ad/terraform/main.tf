resource "proxmox_pool" "BASIC-AD" {
  poolid = "BASIC-AD"
  comment = "Small AD environment for testing"
}

resource "proxmox_vm_qemu" "DC01" {
  # PVE targets
  clone       = var.WINDOWS_SERVER_TEMPLATE
  target_node = var.PROXMOX_NODE

  # VM meta settings
  name        = "DC01"
  desc        = "AD domain controller"
  pool        = "BASIC-AD"
  os_type     = "win11"
  bios        = "ovmf"
  agent       = 1

  # base hardware config
  memory = 8192
  cpu {
    type = "host"
    sockets = 1
    cores = 2
  }

  # disks config
  # includes cloud-init drive
  scsihw = "virtio-scsi-pci"
  disks {
    ide {
      ide1 {
        cloudinit {
          storage = "local-zfs"
        }
      }
    }

    scsi {
      scsi0 {
        disk {
          storage = "local-zfs"
          backup = false
          cache = "writeback"
          discard = true
          size = "50G"
        }
      }
    }
  }

  # network config
  network {
    id = 0
    model = "virtio"
    bridge = "vmbr0"
    firewall = true
  }

  # cloud-init config
  ipconfig0 = var.DC01_IP_CONF
  nameserver = var.DNS_NAMESERVER
  sshkeys = local.INFRA_USER_SSH_PUBLIC_KEY
}

resource "proxmox_vm_qemu" "SERVER01" {
  # PVE targets
  clone       = var.WINDOWS_SERVER_TEMPLATE
  target_node = var.PROXMOX_NODE

  # VM meta settings
  name        = "SERVER01"
  desc        = "AD misc. Windows server"
  pool        = "BASIC-AD"
  os_type     = "win11"
  bios        = "ovmf"
  agent       = 1

  # base hardware config
  memory = 8192
  cpu {
    type = "host"
    sockets = 1
    cores = 2
  }

  # disks config
  # includes cloud-init drive
  scsihw = "virtio-scsi-pci"
  disks {
    ide {
      ide1 {
        cloudinit {
          storage = "local-zfs"
        }
      }
    }

    scsi {
      scsi0 {
        disk {
          storage = "local-zfs"
          backup = false
          cache = "writeback"
          discard = true
          size = "50G"
        }
      }
    }
  }

  # network config
  network {
    id = 0
    model = "virtio"
    bridge = "vmbr0"
    firewall = true
  }

  # cloud-init config
  ipconfig0 = var.SERVER01_IP_CONF
  nameserver = var.DNS_NAMESERVER
  sshkeys = local.INFRA_USER_SSH_PUBLIC_KEY
}

resource "proxmox_vm_qemu" "CLIENT01" {
  # PVE targets
  clone       = var.WINDOWS_CLIENT_TEMPLATE
  target_node = var.PROXMOX_NODE

  # VM meta settings
  name        = "CLIENT01"
  desc        = "AD Windows client"
  pool        = "BASIC-AD"
  os_type     = "win11"
  bios        = "ovmf"
  agent       = 1

  # base hardware config
  memory = 8192
  cpu {
    type = "host"
    sockets = 1
    cores = 2
  }

  # disks config
  # includes cloud-init drive
  scsihw = "virtio-scsi-pci"
  disks {
    ide {
      ide1 {
        cloudinit {
          storage = "local-zfs"
        }
      }
    }

    scsi {
      scsi0 {
        disk {
          storage = "local-zfs"
          backup = false
          cache = "writeback"
          discard = true
          size = "52G"
        }
      }
    }
  }

  # network config
  network {
    id = 0
    model = "virtio"
    bridge = "vmbr0"
    firewall = true
  }

  # cloud-init config
  ipconfig0 = var.CLIENT01_IP_CONF
  nameserver = var.DNS_NAMESERVER
  sshkeys = local.INFRA_USER_SSH_PUBLIC_KEY
}
