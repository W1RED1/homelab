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
echo '[*] Generating new SSH password...'
export PKR_VAR_SSH_PASSWORD=$(openssl rand -hex 32)

# write randomly generated password to autounattend file
echo '[*] Running autounattend update script...'
mkdir -p '/tmp/win2k25'
python3 'scripts/Update-AutounattendPass.py' 'configs/win2k25_autounattend.xml' '/tmp/win2k25/autounattend.xml'
mkdir -p '/tmp/win10'
python3 'scripts/Update-AutounattendPass.py' 'configs/win10_autounattend.xml' '/tmp/win10/autounattend.xml'
mkdir -p '/tmp/win11'
python3 'scripts/Update-AutounattendPass.py' 'configs/win11_autounattend.xml' '/tmp/win11/autounattend.xml'

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
