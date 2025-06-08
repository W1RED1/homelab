# Basic active directory lab
Small active directory environment for testing  
Consists of a single domain controller `DC01`, and two domain members `SERVER01` and `CLIENT01`
  *  Update `basic-ad.auto.tfvars` before building
  *  `build.sh` chains terraform and ansible together
  *  [`pass`](https://www.passwordstore.org/) utility for retreiving generated passwords
