function Main {
    # Setup-SshKeys
    Setup-WorkspaceFiles
    Setup-CursorSettings
    Setup-WorkFolder
    Download-Programs
    Apportable-Setup
}

function Ensure-SshDirectory {
    $sshDir = Join-Path $env:USERPROFILE ".ssh"
    if (-not (Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    }
    return $sshDir
}

function Write-KeyFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content,
        [Parameter(Mandatory = $true)][bool]$IsPrivate
    )

    if ([string]::IsNullOrWhiteSpace($Content)) {
        return
    }

    if ($Content -like "*PASTE_YOUR_*") {
        return
    }

    $normalizedContent = $Content -replace "`r", ""
    $normalizedContent = $normalizedContent -replace "`n+$", ""
    $normalizedContent = $normalizedContent + "`n"

    Set-Content -Path $Path -Value $normalizedContent -Encoding ascii -NoNewline

    if ($IsPrivate) {
        icacls $Path /inheritance:r | Out-Null
        icacls $Path /grant:r "$($env:USERNAME):(R,W)" | Out-Null
    }
}

function Start-SshAgentAndAddKeys {
    param(
        [string[]]$PrivateKeyPaths
    )

    $service = Get-Service -Name "ssh-agent" -ErrorAction SilentlyContinue
    if (-not $service) {
        return
    }

    if ($service.StartType -ne 'Automatic') {
        Set-Service -Name "ssh-agent" -StartupType Automatic
    }

    if ($service.Status -ne 'Running') {
        Start-Service -Name "ssh-agent"
    }

    foreach ($keyPath in $PrivateKeyPaths) {
        if (Test-Path $keyPath) {
            ssh-add $keyPath 2>&1 | Out-Null
        }
    }
}

function Download-WorkspaceFile {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$Path
    )

    try {
        $content = Invoke-WebRequest -Uri $Url -UseBasicParsing -ErrorAction Stop
        $normalizedContent = $content.Content -replace "`r", ""
        $normalizedContent = $normalizedContent -replace "`n+$", ""
        $normalizedContent = $normalizedContent + "`n"
        Set-Content -Path $Path -Value $normalizedContent -Encoding utf8 -NoNewline
    } catch {
    }
}

function Setup-WorkspaceFiles {
    $desktopPath = [Environment]::GetFolderPath('Desktop')
    $baseUrl = "https://raw.githubusercontent.com/judigot/references/refs/heads/main"

    $personalWorkspacePath = Join-Path $desktopPath "Personal.code-workspace"
    $workWorkspacePath = Join-Path $desktopPath "Work.code-workspace"

    Download-WorkspaceFile -Url "$baseUrl/Personal.code-workspace" -Path $personalWorkspacePath
    Download-WorkspaceFile -Url "$baseUrl/Work.code-workspace" -Path $workWorkspacePath
}

function Apportable-Setup {
    curl.exe -L "https://raw.githubusercontent.com/judigot/references/main/Apportable.ps1" | powershell -NoProfile -
}

function Download-Programs {
    # Chrome (failproof: official MSI; avoids winget hash mismatch entirely)
    $u="https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi"; $f="$env:TEMP\chrome_enterprise64.msi"; try{ [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12 }catch{}; try{ Start-BitsTransfer -Source $u -Destination $f -ErrorAction Stop }catch{ Invoke-WebRequest $u -OutFile $f -UseBasicParsing }; Start-Process msiexec.exe -Wait -ArgumentList "/i `"$f`" /qn /norestart"; Remove-Item $f -Force -ErrorAction SilentlyContinue

    # Others (winget source only)
    winget install -e --id Anysphere.Cursor --source winget --silent --accept-package-agreements --accept-source-agreements
    # winget install -e --id ZedIndustries.Zed --source winget --silent --accept-package-agreements --accept-source-agreements
    winget install -e --id Docker.DockerDesktop --source winget --silent --accept-package-agreements --accept-source-agreements
}

function Setup-CursorSettings {
    $cursorUserDir = Join-Path $env:APPDATA "Cursor\User"
    if (-not (Test-Path $cursorUserDir)) {
        New-Item -ItemType Directory -Path $cursorUserDir -Force | Out-Null
    }

    $baseUrl = "https://raw.githubusercontent.com/judigot/vscode/main"
    $snippetsDir = Join-Path $cursorUserDir "snippets"
    if (-not (Test-Path $snippetsDir)) {
        New-Item -ItemType Directory -Path $snippetsDir -Force | Out-Null
    }

    $files = @(
        @{ Name = "Master of Snippets.code-snippets"; UrlName = "Master%20of%20Snippets.code-snippets"; Path = Join-Path $snippetsDir "Master of Snippets.code-snippets" },
        @{ Name = "keybindings.json"; UrlName = "keybindings.jsonc"; Path = Join-Path $cursorUserDir "keybindings.json" },
        @{ Name = "settings.jsonc"; UrlName = "settings.jsonc"; Path = Join-Path $cursorUserDir "settings.jsonc" }
    )

    foreach ($file in $files) {
        $url = "$baseUrl/$($file.UrlName)"
        Download-WorkspaceFile -Url $url -Path $file.Path
    }

    $settingsJsoncPath = Join-Path $cursorUserDir "settings.jsonc"
    $settingsJsonPath = Join-Path $cursorUserDir "settings.json"
    if (Test-Path $settingsJsoncPath) {
        Copy-Item -Path $settingsJsoncPath -Destination $settingsJsonPath -Force
    }
}

function Setup-WorkFolder {
    $desktopPath = [Environment]::GetFolderPath('Desktop')
    $workFolderPath = Join-Path $desktopPath "Work"
    
    if (-not (Test-Path $workFolderPath)) {
        New-Item -ItemType Directory -Path $workFolderPath -Force | Out-Null
    }
}

Main