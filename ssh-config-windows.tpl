$sshConfigPath = "$env:USERPROFILE/.ssh/config"
Add-Content -Path $sshConfigPath -Value @'

Host ${hostname}
    HostName ${hostname}
    IdentityFile ${identityfile}
    User ${user}
'@