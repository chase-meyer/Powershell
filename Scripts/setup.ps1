# Main setup script

param(
    [switch]$InstallPwshIfMissing = $true
)

function Ensure-Pwsh {
    if (Get-Command pwsh -ErrorAction SilentlyContinue) { return }

    if (-not $InstallPwshIfMissing) {
        Write-Warning "'pwsh' (PowerShell 7+) not found. Re-run with -InstallPwshIfMissing to attempt install."
        return
    }

    if ($IsWindows) {
        $winget = Get-Command winget -ErrorAction SilentlyContinue
        if ($winget) {
            Write-Host "Installing PowerShell 7 via winget..."
            winget install --id Microsoft.PowerShell --source winget --scope user --accept-package-agreements --accept-source-agreements
        } else {
            Write-Warning "'pwsh' not found and winget not available. Install PowerShell 7 manually: https://aka.ms/powershell-release"
        }
    } elseif ($IsLinux) {
        Write-Warning "'pwsh' not found. Install PowerShell 7 via your package manager (e.g., sudo apt-get install powershell) or see https://aka.ms/powershell-release."
    } elseif ($IsMacOS) {
        Write-Warning "'pwsh' not found. Install PowerShell 7 via Homebrew: brew install --cask powershell"
    }
}

Ensure-Pwsh

$scriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$profilePath = $PROFILE

Write-Host "Configuring PowerShell profile at $profilePath..."

# Theme path detection for Windows, Linux, WSL
$poshThemesRoot = if ($env:POSH_THEMES_PATH) {
    $env:POSH_THEMES_PATH
} elseif ($IsWindows) {
    Join-Path ([System.Environment]::GetFolderPath('LocalApplicationData')) 'Programs\oh-my-posh\themes'
} else {
    "$HOME/.poshthemes"
}
$poshThemePath = Join-Path $poshThemesRoot 'theme.omp.json'

# Where to place helper scripts
$targetScriptDir = if ($IsWindows) { Join-Path $HOME 'Documents\PowerShell\Scripts' } else { "$HOME/bin" }
if (-not (Test-Path -Path $targetScriptDir)) {
    New-Item -ItemType Directory -Path $targetScriptDir -Force | Out-Null
}

# Copy local scripts to the target script dir (case-safe path)
Copy-Item -Path (Join-Path $scriptRoot '*.ps1') -Destination $targetScriptDir -Force

$profileLines = @()
$profileLines += '# Custom profile settings'
$profileLines += ''
$profileLines += '$emojis = @(''️❤️'', ''👽'', ''💩'', ''🍄'', ''👻'', ''🐷'', ''🥓'', ''🌮'', ''💣'', ''🚒'', ''🚓'', ''🚢'', ''🚕'', ''🚌'', ''🚂'', ''🚛'', ''🍇'', ''🍈'', ''🍉'', ''🍊'', ''🍋'', ''🍌'', ''🍍'', ''🥭'', ''🍎'', ''🍏'', ''🍐'', ''🍑'', ''🍒'', ''🍓'', ''🥝'', ''🍅'', ''🥥'', ''🥑'', ''🥒'', ''🥦'', ''🫑'', ''🌵'', ''🐫'', ''🦖'', ''🐳'', ''🐓'', ''🐵'')'
$profileLines += '$randomEmoji = $emojis[(Get-Random -Minimum 0 -Maximum $emojis.Length)]'
$profileLines += "`$poshThemePath = '$poshThemePath'"
$profileLines += 'if (Test-Path $poshThemePath) {'
$profileLines += '    $theme = Get-Content -Path $poshThemePath -Raw | ConvertFrom-Json -AsHashtable'
$profileLines += '    $theme.blocks.segments[7].template = $randomEmoji'
$profileLines += '    $theme | ConvertTo-Json -Depth 100 | Set-Content -Path $poshThemePath'
$profileLines += '}'
$profileLines += '$poshPaths = @(''/usr/local/bin'', "$HOME/.local/bin")'
$profileLines += '$segments = $env:PATH -split '':'''
$profileLines += 'foreach ($p in $poshPaths) { if ($p -and -not ($segments -contains $p)) { $segments += $p } }'
$profileLines += '$env:PATH = ($segments -join '':'')'
$profileLines += 'if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {'
$profileLines += '    oh-my-posh init pwsh --config $poshThemePath | Invoke-Expression'
$profileLines += '} else {'
$profileLines += '    Write-Verbose "oh-my-posh not installed; skipping prompt init"'
$profileLines += '}'
$profileLines += ''
$profileLines += '# Add scripts dir to PATH if not already included'
$profileLines += "if (-not ((`$env:PATH -split [IO.Path]::PathSeparator) -contains '$targetScriptDir')) { [System.Environment]::SetEnvironmentVariable('PATH', `$env:PATH + [IO.Path]::PathSeparator + '$targetScriptDir', [System.EnvironmentVariableTarget]::User) }"

if ($profilePath) {
    $profileDir = Split-Path -Path $profilePath -Parent
    if ($profileDir -and -not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    Set-Content -Path $profilePath -Value $profileLines
}

Write-Host "PowerShell profile configured successfully!"

# Install Oh My Posh (Windows script), otherwise expect it to be installed via package manager
if ($IsWindows) {
    Write-Host "Installing Oh My Posh..."
    & (Join-Path $scriptRoot 'install-ohmyposh.ps1')
} else {
    Write-Host "Skipping install-ohmyposh.ps1 (install oh-my-posh via your package manager or curl script on WSL)."
}

# Configure settings
Write-Host "Configuring settings..."
$configureScript = Join-Path $scriptRoot 'configure-settings.ps1'
if (Test-Path $configureScript) {
    & $configureScript
} else {
    Write-Warning "configure-settings.ps1 not found at $configureScript"
}

Write-Host "Custom scripts copied and PATH updated successfully!"
Write-Host "Setup complete! Please restart your PowerShell session to apply the profile settings."