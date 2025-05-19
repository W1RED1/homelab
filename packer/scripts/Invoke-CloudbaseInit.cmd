@echo off
:: Execute Cloudbase-Init following OOBE setup phase
:: This ensures hostname is set correctly, not randomized
:: This command was taken directly from the default Cloudbase-Init unattend file
cmd.exe /c ""C:\Program Files\Cloudbase Solutions\Cloudbase-Init\Python\Scripts\cloudbase-init.exe" --config-file "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf" && exit 1 || exit 2"
