# Check whether MSI installer and config files exist or not
$files_exist = (Test-Path -Path 'C:\Windows\Temp\CloudbaseInitSetup_Stable_x64.msi') -and
               (Test-Path -Path 'C:\Windows\Temp\cloudbase-init-unattend.conf') -and
               (Test-Path -Path 'C:\Windows\Temp\cloudbase-unattend.xml') -and
               (Test-Path -Path 'C:\Windows\Temp\Disable-DefaultLocalAdmin.ps1') -and
               (Test-Path -Path 'C:\Windows\Temp\Invoke-CloudbaseInit.cmd')

if ($files_exist) {
    Write-Host '[*] Cloudbase-Init files located'
} else {
    Write-Host '[!] ERROR: Expected Cloudbase-Init files not found'
    exit 1
}

# Execute MSI file to install Cloudbase-Init
Write-Host '[*] Running Cloudbase-Init MSI...'
Start-Process 'msiexec.exe' -ArgumentList '/i C:\Windows\Temp\CloudbaseInitSetup_Stable_x64.msi /qn /norestart RUN_SERVICE_AS_LOCAL_SYSTEM=1' -Wait

# Loop until Cloudbase-Init conf directory is created
Write-Host '[*] Waiting for Cloudbase-Init config directory to be created...'
while (-not (Test-Path -Path 'C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\')) {
    Start-Sleep -Seconds 1
}

# Overwrite default Cloudbase-Init configs
Write-Host '[*] Copying Cloudbase-Init configuration files...'
Remove-Item -Path 'C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf'
Copy-Item -Path 'C:\Windows\Temp\cloudbase-init-unattend.conf' -Destination 'C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf' -Force
Copy-Item -Path 'C:\Windows\Temp\cloudbase-unattend.xml' -Destination 'C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml' -Force

# Copy over additional scripts
Write-Host '[*] Copying additional scripts...'
Copy-Item -Path 'C:\Windows\Temp\Disable-DefaultLocalAdmin.ps1' -Destination 'C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\Disable-DefaultLocalAdmin.ps1'
# Invoke-CloudbaseInit.cmd will execute following OOBE setup phase
# Prevents conflict between Cloudbase-Init and hostname randomization during setup
New-Item -ItemType 'File' -Path 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Force | Out-Null
Copy-Item -Path 'C:\Windows\Temp\Invoke-CloudbaseInit.cmd' -Destination 'C:\Windows\Setup\Scripts\SetupComplete.cmd'

# Set Cloudbase-Init service to disabled
# Prevents execution at every reboot
Write-Host '[*] Disabling Cloudbase-Init service...'
Set-Service -Name 'cloudbase-init' -StartupType 'Disabled'

# Delete temporary files
Write-Host '[*] Cleaning up temporary files...' 
Remove-Item -Path 'C:\Windows\Temp\CloudbaseInitSetup_Stable_x64.msi'
Remove-Item -Path 'C:\Windows\Temp\cloudbase-init-unattend.conf'
Remove-Item -Path 'C:\Windows\Temp\cloudbase-unattend.xml'
Remove-Item -Path 'C:\Windows\Temp\Disable-DefaultLocalAdmin.ps1'
Remove-Item -Path 'C:\Windows\Temp\Invoke-CloudbaseInit.cmd'
