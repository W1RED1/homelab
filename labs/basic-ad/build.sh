echo '[*] Generating new SSH key pair for infra user...'
ssh-keygen -f $(pwd)/infra_id_ed25519 -N '' -q

# terraform passes public key to cloud-init
# ansible uses private key for post-deployment configs
export TF_VAR_INFRA_SSH_PUBLIC_KEY_PATH=$(pwd)/infra_id_ed25519.pub
export ANSIBLE_PRIVATE_KEY_FILE=$(pwd)/infra_id_ed25519

echo '[*] Lauching terraform...'
terraform -chdir=terraform/ init
terraform -chdir=terraform/ apply

echo '[*] Resolving initial domain passwords...'
if ! pass show BASIC-AD/DEFAULT_DA_USER_PASSWORD >/dev/null 2>&1; then
        pass generate BASIC-AD/DEFAULT_DA_USER_PASSWORD 25
fi

if ! pass show BASIC-AD/DOMAIN_SAFE_MODE_PASSWORD >/dev/null 2>&1; then
        pass generate BASIC-AD/DOMAIN_SAFE_MODE_PASSWORD 25
fi

export DEFAULT_DA_USER_PASSWORD=$(pass BASIC-AD/DEFAULT_DA_USER_PASSWORD)
export DOMAIN_SAFE_MODE_PASSWORD=$(pass BASIC-AD/DOMAIN_SAFE_MODE_PASSWORD)

echo '[*] Installing ansible modules...'
ansible-galaxy install -r ansible/requirements.yml

echo '[*] Executing ansible playbooks...'
export ANSIBLE_CONFIG=$(pwd)/ansible/ansible.cfg
ansible-playbook ansible/playbooks/Update-Windows.yml
ansible-playbook ansible/playbooks/Create-Domain.yml
ansible-playbook ansible/playbooks/Join-Domain.yml
ansible-playbook ansible/playbooks/Enable-AdminServices.yml
