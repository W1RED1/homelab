# Start PS transcript
Start-Transcript -Path 'C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\Disable-DefaultLocalAdmin-PS-transcript.log'

# Randomize default local administrator account password
Write-Host '[*] Generating random password...'
Add-Type -AssemblyName 'System.Web'
$password = [System.Web.Security.Membership]::GeneratePassword(20, 5)
$password = ConvertTo-SecureString -String $password -AsPlainText -Force

Write-Host '[*] Setting default local admin password...'
Set-LocalUser -Name 'Administrator' -Password $password

# Disable default local administrator account to prevent any sign-ins
Write-Host '[*] Disabling default local admin account...'
Disable-LocalUser -Name 'Administrator'
Get-LocalUser -Name 'Administrator' | Select-Object *
