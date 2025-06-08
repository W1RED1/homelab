# Homelab infra-as-code
Sets of configs/scripts for automating builds of lab environments
  *  `Dockerfile` for building docker image with IaC tools installed
  *  `templates` contents used to build Proxmox templates of Windows 10/11/2k25 
  *  `labs` contents breaks out into build files for various lab environments

Docker build/run one-liner assumes no other docker images exist:
```
sudo docker build - < Dockerfile && sudo docker run -v $(pwd):/homelab/ -it $(sudo docker images -q) /bin/bash
```

KEEP LEARNING AND HAPPY HACKING
