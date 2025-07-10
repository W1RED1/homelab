VERSIONS=('2k25' 'w11' 'w10')
VIRTIO_URL='https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso'
CLOUDBASE_URL='https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi'

# download and extract virtio drivers
echo '[*] Fetching VirtIO drivers...'
mkdir -p '/tmp/virtio'
wget $VIRTIO_URL -q --show-progress -O /tmp/virtio-win.iso
echo '[*] Extracting VirtIO drivers...'
7z x -bso0 -o'/tmp/virtio/' '/tmp/virtio-win.iso'

# download cloudbase-init installer
echo '[*] Fetching Cloudbase-Init installer...'
wget $CLOUDBASE_URL -q --show-progress -P /tmp/

# generate SSH password for initial configs
# must happen before initial CD image is prepped
# this password gets written to autounattend files
echo '[*] Generating new SSH password...'
export PKR_VAR_SSH_PASSWORD=$(pwgen -sy 25 1)

# prepare drivers, guest tools/agent, and autounattend files
for VERSION in "${VERSIONS[@]}"
do
	echo "[*] Preparing $VERSION installation files..."
	mkdir -p "/tmp/$VERSION" "/tmp/$VERSION/NetKVM" "/tmp/$VERSION/vioscsi"
	cp -r "/tmp/virtio/NetKVM/$VERSION" "/tmp/$VERSION/NetKVM"
	cp -r "/tmp/virtio/vioscsi/$VERSION" "/tmp/$VERSION/vioscsi"
	cp '/tmp/virtio/virtio-win-gt-x64.msi' "/tmp/$VERSION/virtio-win-gt-x64.msi"
	cp -r '/tmp/virtio/guest-agent' "/tmp/$VERSION/guest-agent"
	python3 'scripts/Update-AutounattendPass.py' "configs/${VERSION}_autounattend.xml" "/tmp/${VERSION}/autounattend.xml"
done

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
for VERSION in "${VERSIONS[@]}"
do
	rm -rf "/tmp/$VERSION"
done
