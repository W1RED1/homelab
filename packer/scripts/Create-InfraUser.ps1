# Create new local admin user 'infra' with randomized password
Write-Host '[*] Generating random password...'
Add-Type -AssemblyName 'System.Web'
$password = [System.Web.Security.Membership]::GeneratePassword(20, 5)
$password = ConvertTo-SecureString -String $password -AsPlainText -Force

Write-Host '[*] Creating new local user ''infra'''...
New-LocalUser -Name 'infra' -Password $password -Description 'User for infra-as-code deployments' | Out-Null

Write-Host '[*] Adding ''infra'' user to local admin group...'
Add-LocalGroupMember -Group 'Users' -Member 'infra'
Add-LocalGroupMember -Group 'Administrators' -Member 'infra'

# Execute whoami.exe as user 'infra' to force creation of user profile directories
Write-Host '[*] Forcing creation of ''infra'' user profile...'
$credential = New-Object System.Management.Automation.PSCredential('infra', $password)
Start-Process 'whoami.exe' -Credential $credential -LoadUserProfile -Wait
