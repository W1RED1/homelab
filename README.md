# Homelab infra-as-code
Sets of configs/scripts for automating builds of lab environments
  *  `Dockerfile` for building docker image with IaC tools installed
  *  `templates` contents used to build Proxmox templates of Windows 10/11/2k25 
  *  `labs` contents breaks out into build files for various lab environments

Initial IaC build processes generate secrets such as passwords which may need to be remembered for idempotency  
Bootstrap script generates a password-protected GPG key which is used to initialize a password store  
Some persistent storage mechanism is needed to carry these between containers which may be destroyed over time  

Running new instances of the docker image will create a new volume by default:
```
sudo docker build -t iac .
sudo docker run -it iac
# ... perform IaC builds and exit ...
sudo docker start -ia [PREVIOUS CONTAINER ID]
# ... same container re-mounts generated volume ...
```

Explicit host FS location or docker volume required when using auto-remove option:
```
sudo docker build -t iac .
sudo docker run -it --rm -v $(pwd):/homelab iac
sudo docker run -it --rm -v lab_volume_1:/homelab iac
# ... perform IaC builds and exit ...
# ... repeat run command to persist secret storage in new container ...
```

KEEP LEARNING AND HAPPY HACKING
