# Template build files
Various configs/scripts for automating template build processes
  *  [`packer`](https://developer.hashicorp.com/packer) with [Proxmox integration](https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox) leverages the Proxmox API
  *  [Cloudbase-Init](https://cloudbase.it/cloudbase-init/) provides cloud-init functionality for Windows hosts
  *  `build.sh` downloads/stages needed files and starts packer build
  *  Initial autounattend passwords are randomized on every build
  *  Templates build according to [Windows guest best practices (Proxmox wiki)](https://pve.proxmox.com/mediawiki/index.php?search=Windows+best+practices)

Create a user, role, and token with [minimum permissions](https://github.com/hashicorp/packer-plugin-proxmox/issues/184)  
Some build tasks may require additional permissions (YMMV)
```
pveum useradd username@pve
pveum roleadd Packer -privs "VM.Config.Disk VM.Config.CPU VM.Config.Memory Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Pool.Allocate SDN.Use Sys.Modify VM.Config.Options VM.Allocate VM.Audit VM.Console VM.Config.CDROM VM.Config.Network VM.Config.Cloudinit VM.PowerMgmt VM.Config.HWType VM.Monitor"
pveum aclmod / -user username@pve -role Packer
pveum user token add username@pve tokenname --privsep 0
```
