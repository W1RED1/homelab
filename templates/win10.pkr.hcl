source "proxmox-iso" "win10" {
  vm_name = "WIN-10-TEMPLATE-VM"
  template_name = "WIN-10-TEMPLATE"
  template_description = "Windows 10 template generated with packer"
  pool = "TEMPLATES"
  os = "win10"
  qemu_agent = true

  # communicator config
  ssh_username = var.SSH_USERNAME
  ssh_password = var.SSH_PASSWORD
  ssh_timeout = "1h"

  # connection config
  proxmox_url = var.PROXMOX_URL
  username = var.PROXMOX_USERNAME
  token = var.PROXMOX_TOKEN
  insecure_skip_tls_verify = "true"
  node = var.PROXMOX_NODE

  # base hardware config
  cpu_type = "host"
  sockets = "1"
  cores = "2"
  memory = "8192"
  machine = "q35"

  # efi config
  bios = "ovmf"
  efi_config {
    efi_storage_pool = "local-zfs"
    efi_format = "raw"
    pre_enrolled_keys = true
    efi_type = "4m"
  }

  # network adapter config
  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
    firewall = true
  }

  # main drive config
  scsi_controller = "virtio-scsi-pci"
  disks {
    type = "scsi"
    storage_pool = "local-zfs"
    disk_size = "50G"
    cache_mode = "writeback"
    format = "raw"
    exclude_from_backup = true
    discard = true
  }

  # cloud-init drive config
  cloud_init = true
  cloud_init_storage_pool = "local-zfs"
  cloud_init_disk_type = "ide"

  # iso configs
  boot_iso {
    iso_file = "local:iso/Windows-10-eval-amd64.iso"
    unmount = true    
  }

  additional_iso_files {
    cd_files = [
      "/tmp/virtio/*",
      "/tmp/CloudbaseInitSetup_Stable_x64.msi",
      "/tmp/win10/autounattend.xml",
      "scripts/Install-WindowsUpdates.ps1",
      "scripts/Install-OpenSSH.ps1",
      "configs/sshd_config"
    ]
    cd_label = "autoinstall"
    iso_storage_pool = "local"
    unmount = true
  }

  # initial boot config
  boot = "order=scsi0;ide2;ide0"
  boot_wait = "5s"
  boot_command = [
    "<enter>"
  ]
}

build {
  sources = ["source.proxmox-iso.win10"]

  provisioner "powershell" {
    script = "scripts/Create-InfraUser.ps1"
  }

  provisioner "file" {
    sources = [
      "/tmp/CloudbaseInitSetup_Stable_x64.msi",
      "configs/cloudbase-init-unattend.conf",
      "configs/cloudbase-unattend.xml",
      "scripts/Disable-DefaultLocalAdmin.ps1",
      "scripts/Invoke-CloudbaseInit.cmd"
    ]
    destination = "C:/Windows/Temp/"
  } 

  provisioner "powershell" {
    script = "scripts/Install-CloudbaseInit.ps1"
  }

  provisioner "powershell" {
    inline = [
      "Write-Host '[*] Running Sysprep...'",
      "cd 'C:\\Program Files\\Cloudbase Solutions\\Cloudbase-Init\\conf'",
      "Start-Process 'C:\\Windows\\System32\\Sysprep\\Sysprep.exe' -ArgumentList '/generalize /oobe /quiet /quit /unattend:Unattend.xml' -Wait",
    ]
  }
}
