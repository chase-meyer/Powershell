param(
    [string]$NamePath   = (Join-Path $PSScriptRoot 'modules.txt'),
    [string]$PinnedPath = (Join-Path $PSScriptRoot 'modules-pinned.txt')
)

$installed = Get-InstalledModule |
    Sort-Object Name, Version -Descending |
    Group-Object Name |
    ForEach-Object { $_.Group | Select-Object -First 1 } |
    Sort-Object Name

$targets = @(
    @{ Path = $NamePath;   Data = $installed | Select-Object -ExpandProperty Name }
    @{ Path = $PinnedPath; Data = $installed | ForEach-Object { "$($_.Name),$($_.Version)" } }
)

foreach ($target in $targets) {
    $dir = Split-Path -Path $target.Path -Parent
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }

    $target.Data | Set-Content -Path $target.Path
    Write-Host "Wrote $($target.Path)"
}
