param(
    [string]$Path       = (Join-Path $PSScriptRoot 'modules-pinned.txt'),
    [string]$Repository = 'PSGallery',
    [string]$Scope      = 'CurrentUser',
    [switch]$Pinned,
    [switch]$Latest
)

$lines = Get-Content -Path $Path -ErrorAction Stop |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

$usePinned = $Pinned -or (($lines | Where-Object { $_ -match ',' } | Measure-Object).Count -gt 0)

function Install-ByName {
    param([string]$Name)

    $existing = Get-InstalledModule -Name $Name -ErrorAction SilentlyContinue

    if ($Latest) {
        Write-Host "Installing/Updating $Name (latest) from $Repository..."
        Install-Module -Name $Name -Repository $Repository -Scope $Scope -Force -AllowClobber
        return
    }

    if ($existing) {
        Write-Host "$Name already installed ($($existing.Version))."
        return
    }

    Write-Host "Installing $Name..."
    Install-Module -Name $Name -Repository $Repository -Scope $Scope -Force -AllowClobber
}

function Install-ByPinned {
    param([string]$Name, [string]$Version)

    $existing = Get-InstalledModule -Name $Name -ErrorAction SilentlyContinue

    if ($Latest) {
        Write-Host "Installing/Updating $Name (latest) from $Repository..."
        Install-Module -Name $Name -Repository $Repository -Scope $Scope -Force -AllowClobber
        return
    }

    if ($existing -and ($existing.Version -eq [version]$Version)) {
        Write-Host "$Name $Version already installed."
        return
    }

    if ($existing) {
        Write-Host "Updating $Name from $($existing.Version) to $Version..."
    } else {
        Write-Host "Installing $Name $Version..."
    }

    Install-Module -Name $Name -RequiredVersion $Version -Repository $Repository -Scope $Scope -Force -AllowClobber
}

if ($usePinned) {
    foreach ($line in $lines) {
        if ($line -notmatch '^\s*([^,]+)\s*,\s*([\d\.]+)\s*$') {
            Write-Warning "Skipping malformed line: $line"
            continue
        }

        Install-ByPinned -Name $matches[1] -Version $matches[2]
    }
} else {
    $names = $lines | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Sort-Object -Unique

    foreach ($name in $names) {
        Install-ByName -Name $name
    }
}
