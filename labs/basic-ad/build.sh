echo '[*] Generating new SSH key pair for infra user...'
ssh-keygen -f $(pwd)/infra_id_ed25519 -N '' -q

# terraform passes public key to cloud-init
# ansible uses private key for post-deployment configs
export TF_VAR_INFRA_SSH_PUBLIC_KEY_PATH=$(pwd)/infra_id_ed25519.pub
export ANSIBLE_PRIVATE_KEY_FILE=$(pwd)/infra_id_ed25519

echo '[*] Lauching terraform...'
terraform -chdir=terraform/ init
terraform -chdir=terraform/ apply -auto-approve

# password store holds generated credentials until container is destroyed
echo '[*] Initializing password store...'
gpg --batch --passphrase '' --quick-gen-key $(whoami)
pass init $(gpg --list-secret-keys --with-colons | awk -F: '$1 == "fpr" {print $10}' | head -1)

echo '[*] Generating initial domain passwords...'
pass generate -f BASIC-AD/DEFAULT_DA_USER_PASSWORD 25
pass generate -f BASIC-AD/DOMAIN_SAFE_MODE_PASSWORD 25
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
