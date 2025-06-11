# download and extract virtio drivers
echo '[*] Fetching VirtIO drivers...'
mkdir -p '/tmp/virtio'
wget 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso' -q --show-progress -O /tmp/virtio-win.iso
echo '[*] Extracting VirtIO drivers...'
7z x -bso0 -o'/tmp/virtio/' '/tmp/virtio-win.iso'

# download cloudbase-init installer
echo '[*] Fetching Cloudbase-Init installer...'
wget 'https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi' -q --show-progress -P /tmp/

# generate SSH password for initial configs
# must happen before initial CD image is prepped
# this password gets written to autounattend files
echo '[*] Generating new SSH password...'
export PKR_VAR_SSH_PASSWORD=$(pwgen -sy 25 1)

# prepare drivers, guest tools/agent, and autounattend files
echo '[*] Preparing Windows 2025 installation files...'
mkdir -p '/tmp/win2k25' '/tmp/win2k25/NetKVM' '/tmp/win2k25/vioscsi'
cp -r '/tmp/virtio/NetKVM/2k25' '/tmp/win2k25/NetKVM'
cp -r '/tmp/virtio/vioscsi/2k25' '/tmp/win2k25/vioscsi'
cp '/tmp/virtio/virtio-win-gt-x64.msi' '/tmp/win2k25/virtio-win-gt-x64.msi'
cp -r '/tmp/virtio/guest-agent' '/tmp/win2k25/guest-agent'
python3 'scripts/Update-AutounattendPass.py' 'configs/win2k25_autounattend.xml' '/tmp/win2k25/autounattend.xml'

echo '[*] Preparing Windows 11 installation files...'
mkdir -p '/tmp/win11' '/tmp/win11/NetKVM' '/tmp/win11/vioscsi'
cp -r '/tmp/virtio/NetKVM/w11' '/tmp/win11/NetKVM'
cp -r '/tmp/virtio/vioscsi/w11' '/tmp/win11/vioscsi'
cp '/tmp/virtio/virtio-win-gt-x64.msi' '/tmp/win11/virtio-win-gt-x64.msi'
cp -r '/tmp/virtio/guest-agent' '/tmp/win11/guest-agent'
python3 'scripts/Update-AutounattendPass.py' 'configs/win11_autounattend.xml' '/tmp/win11/autounattend.xml'

echo '[*] Preparing Windows 10 installation files...'
mkdir -p '/tmp/win10' '/tmp/win10/NetKVM' '/tmp/win10/vioscsi'
cp -r '/tmp/virtio/NetKVM/w10' '/tmp/win10/NetKVM'
cp -r '/tmp/virtio/vioscsi/w10' '/tmp/win10/vioscsi'
cp '/tmp/virtio/virtio-win-gt-x64.msi' '/tmp/win10/virtio-win-gt-x64.msi'
cp -r '/tmp/virtio/guest-agent' '/tmp/win10/guest-agent'
python3 'scripts/Update-AutounattendPass.py' 'configs/win10_autounattend.xml' '/tmp/win10/autounattend.xml'

# prompt for PVE token vars
echo ''
echo 'var.PROXMOX_TOKEN_ID'
echo '  PVE API token ID (ex. username@pve!tokenname)'
read -p '  Enter a value: ' PKR_VAR_PROXMOX_TOKEN_ID
echo ''
export PKR_VAR_PROXMOX_TOKEN_ID

echo 'var.PROXMOX_TOKEN_SECRET'
echo '  PVE API token UUID secret (ex. 00000000-0000-0000-0000-000000000000)'
read -s -p '  Enter a value: ' PKR_VAR_PROXMOX_TOKEN_SECRET
export PKR_VAR_PROXMOX_TOKEN_SECRET
echo ''

echo '[*] Launching packer...'
export PKR_VAR_TEMPLATE_TIMESTAMP=$(date)
cd packer
packer init .
packer build .

# delete temp files
echo '[*] Cleaning temporary files...'
rm -rf '/tmp/virtio-win.iso'
rm -rf '/tmp/virtio'
rm -rf '/tmp/CloudbaseInitSetup_Stable_x64.msi'
rm -rf '/tmp/win2k25'
rm -rf '/tmp/win10'
rm -rf '/tmp/win11'
