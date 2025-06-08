# PVE target
# token ID and secret prompted at runtime
PROXMOX_URL = "https://127.0.0.1:8006/api2/json"
PROXMOX_NODE = "nodename"

# templates to clone
WINDOWS_CLIENT_TEMPLATE = "WIN-11-TEMPLATE"
WINDOWS_SERVER_TEMPLATE = "WIN-2K25-TEMPLATE"

# vm clone IP configs
DNS_NAMESERVER = "192.168.0.1"
DC01_IP_CONF = "ip=192.168.0.2/24,gw=192.168.0.1"
SERVER01_IP_CONF = "ip=192.168.0.3/24,gw=192.168.0.1"
CLIENT01_IP_CONF = "ip=dhcp"

# name of resulting AD domain
DOMAIN_NAME = "example.local"
