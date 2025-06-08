# ensures delay between cloning and ansible playbooks
# allows Cloudbase-Init time to execute
resource "time_sleep" "delay" {
  depends_on = [proxmox_vm_qemu.DC01, proxmox_vm_qemu.SERVER01, proxmox_vm_qemu.CLIENT01]
  create_duration = "5m"
}

# hosts for ansible inventory
resource "ansible_host" "DC01" {
  depends_on = [time_sleep.delay]
  name = proxmox_vm_qemu.DC01.ssh_host
  groups = ["PDC"]
  variables = {
    ansible_shell_type = "powershell"
  }
}

resource "ansible_host" "SERVER01" {
  depends_on = [time_sleep.delay]
  name = proxmox_vm_qemu.SERVER01.ssh_host
  groups = ["servers"]
  variables = {
    ansible_shell_type = "powershell"
  }
}

resource "ansible_host" "CLIENT01" {
  depends_on = [time_sleep.delay]
  name = proxmox_vm_qemu.CLIENT01.ssh_host
  groups = ["clients"]
  variables = {
    ansible_shell_type = "powershell"
  }
}

# group containing all domain controllers
resource "ansible_group" "controllers" {
  depends_on = [ansible_host.DC01]
  name = "controllers"
  children = ["PDC", "BDC"]
}

# group containing all member servers/clients
resource "ansible_group" "members" {
  depends_on = [ansible_host.SERVER01, ansible_host.CLIENT01]
  name = "members"
  children = ["servers", "clients"]
}

# group containing all domain machines
resource "ansible_group" "domain" {
  depends_on = [ansible_group.controllers, ansible_group.members]
  name = "domain"
  children = ["controllers", "members"]
  variables = {
    DOMAIN_NAME = var.DOMAIN_NAME
    PDC_IP_ADDR = proxmox_vm_qemu.DC01.ssh_host
  }
}
