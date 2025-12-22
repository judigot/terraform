<powershell>
try { Start-Transcript -Path "C:\user-data.log" -Append | Out-Null } catch {}

# Set the local Administrator password from Terraform variable
$PasswordPlain = "${windows_admin_password}"
$Password = ConvertTo-SecureString $PasswordPlain -AsPlainText -Force
Set-LocalUser -Name "Administrator" -Password $Password
Enable-LocalUser -Name "Administrator"
New-Item -Path "C:\_bootstrapped_password.txt" -ItemType File -Force | Out-Null


# Download Init.ps1 to Administrator Desktop
New-Item -ItemType Directory -Force -Path "C:\Users\Administrator\Desktop" | Out-Null

try {
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

    $url = "${init_ps1_url}"
    Invoke-WebRequest -Uri $url -OutFile "C:\Users\Administrator\Desktop\Init.ps1" -UseBasicParsing -ErrorAction Stop
    New-Item -ItemType File -Path "C:\Status - Init.ps1 downloaded" -Force | Out-Null
} catch {
    New-Item -ItemType File -Path "C:\Status - Init.ps1 download FAILED" -Force | Out-Null
    $_ | Out-String | Set-Content -Path "C:\Status - Init.ps1 download FAILED - exception.txt" -Encoding utf8

    # Capture S3 XML error response body (this is the money)
    try {
        if ($_.Exception.Response -and $_.Exception.Response.GetResponseStream()) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $body = $reader.ReadToEnd()
            $reader.Close()
            $body | Set-Content -Path "C:\Status - Init.ps1 download FAILED - response.xml" -Encoding utf8
        }
    } catch {
        # no-op
    }
}

New-Item -ItemType File -Path "C:\Status - user-data completed" -Force | Out-Null
</powershell>
