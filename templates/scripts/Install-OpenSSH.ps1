# Ensure OpenSSH server is installed
if (-not (Get-Service -Name sshd -ErrorAction SilentlyContinue)) {
    Write-Host '[*] Installing OpenSSH server...'
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
} else {
    Write-Host '[*] OpenSSH server already installed'
}

# Start PS transcript
Start-Transcript -Path 'C:\ProgramData\ssh\logs\Install-OpenSSH-PS-transcript.log'

# Overwite default OpenSSH server config
Write-Host '[*] Copying OpenSSH sshd_config file...'
Copy-Item -Path "D:\sshd_config" -Destination 'C:\ProgramData\ssh\sshd_config' -Force

# Set OpenSSH server to automatic startup
Write-Host '[*] Setting OpenSSH to automatic startup...'
Set-Service -Name sshd -StartupType 'Automatic'

# Set default shell as powershell
Write-Host '[*] Setting OpenSSH default shell to powershell...'
$key = 'HKLM:\SOFTWARE\OpenSSH'
$entry = 'DefaultShell'
$value = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
New-ItemProperty -Path $key -Name $entry -Value $value -PropertyType String -Force | Out-Null

# Apply OpenSSH firewall rule to all profiles
Write-Host '[*] Changing OpenSSH server firewall rule profiles...'
$rule = 'OpenSSH-Server-In-TCP'
Set-NetFirewallRule -Name $rule -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -Profile Any

# Start OpenSSH service
Write-Host "[*] Starting OpenSSH..."
Start-Service sshd
