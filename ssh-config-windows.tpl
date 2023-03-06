add-content -path C:/users/Jude/.ssh/config -value @'

Host ${hostname}
    HostName ${hostname}
    IdentityFile ${identityfile}
    User ${user}
'@