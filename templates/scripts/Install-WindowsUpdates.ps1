# Ensure NuGet package provider is installed
$providers = Get-PackageProvider | Select-Object -ExpandProperty Name
if (-not $providers.Contains('NuGet')) {
    Write-Host '[*] Installing NuGet package provider...'
    Install-PackageProvider -Name NuGet -Force
} else {
    Write-Host '[*] NuGet package provider already installed'
}

# Ensure PSWindowsUpdate module is installed
$modules = Get-Module -ListAvailable | Select-Object -ExpandProperty Name
if (-not $modules.Contains('PSWindowsUpdate')) {
    Write-Host '[*] Installing PSWindowsUpdate module...'
    Install-Module -Name PSWindowsUpdate -Force
} else {
    Write-Host '[*] PSWindowsUpdate module already installed'
}

Import-Module PSWindowsUpdate

# Install any pending updates
Write-Host '[*] Checking for Windows updates...'
$key = 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
$entry = 'WindowsUpdates'
$value = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ep bypass -file D:\Install-WindowsUpdates.ps1'

if ((Get-WindowsUpdate).Count -gt 0) {
    Write-Host '[*] Installing Windows updates...'
    Install-WindowsUpdate -AcceptAll -IgnoreReboot

    # Ensure WindowsUpdates autorun registry entry exists
    if (-not (Get-ItemProperty -Path $key -Name $entry -ErrorAction SilentlyContinue)) {
        Write-Host '[*] Creating registry run key entry...'
        Set-ItemProperty -Path $key -Name $entry -Value $value
    } else {
        Write-Host '[*] Registry run key entry already exists'
    }

    Write-Host '[*] Rebooting...'
    Restart-Computer -Force
} else {
    Write-Host '[*] No updates found...'
    Write-Host '[*] Removing registry run key entry...'
    Remove-ItemProperty -Path $key -Name $entry

    # Execute script to configure OpenSSH so Packer can connect
    Write-Host '[*] Executing script to enable OpenSSH...'
    D:\Install-OpenSSH.ps1
}
