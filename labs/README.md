# Lab build files
Each directory contains configs/scripts to build a specific lab environment
  *  [`terraform`](https://developer.hashicorp.com/terraform) with [Proxmox](https://registry.terraform.io/providers/aravindc/proxmox/latest/docs)/[Ansible](https://registry.terraform.io/providers/ansible/ansible/latest/docs) providers for cloning and tracking inventory
  *  [`ansible`](https://docs.ansible.com/ansible/latest/index.html) for post-deployment configurations

Create a user, role, and token with [minimum permissions](https://registry.terraform.io/providers/aravindc/proxmox/latest/docs#creating-the-proxmox-user-and-role-for-terraform)
```
pveum useradd username@pve
pveum roleadd Terraform -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"
pveum aclmod / -user username@pve -role Terraform
pveum user token add username@pve tokenname --privsep 0
```
