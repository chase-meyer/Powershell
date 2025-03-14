# Main setup script

# Define the profile path
$profilePath = $PROFILE

# Create or update the profile script
Write-Host "Configuring PowerShell profile at $profilePath..."

# Profile content
$profileContent = @"
# Custom profile settings

# Get random emoji for Oh My Posh theme prompt
$emojis = @('️❤️', '👽', '💩', '🍄', '👻', '🐷', '🥓', '🌮', '💣', '🚒', '🚓', '🚢', '🚕', '🚌', '🚂', '🚛', '🍇', '🍈', '🍉', '🍊', '🍋', '🍌', '🍍', '🥭', '🍎', '🍏', '🍐', '🍑', '🍒', '🍓', '🥝', '🍅', '🥥', '🥑', '🥒', '🥦', '🫑', '🌵', '🐫', '🦖', '🐳', '🐓', '🐵')
$randomEmoji = $emojis[(Get-Random -Minimum 0 -Maximum $emojis.Length)]

# path to the Oh My Posh theme file
$homeDir = [System.Environment]::GetFolderPath('UserProfile')
$path = "$homeDir\AppData\Local\Programs\oh-my-posh\themes\mytheme.omp.json"

# Update the Oh My Posh theme with the random emoji
$theme = Get-Content -Path $path -Raw | ConvertFrom-Json -AsHashtable
$theme.blocks.segments[7].template = $randomEmoji
$theme | ConvertTo-Json -Depth 100 | Set-Content -Path $path

# Initialize
oh-my-posh init pwsh --config $path | Invoke-Expression
"@

# Write the profile content to the profile script
Set-Content -Path $profilePath -Value $profileContent

Write-Host "PowerShell profile configured successfully!"

# Install Oh My Posh
Write-Host "Installing Oh My Posh..."
./install-ohmyposh.ps1

# Configure settings
Write-Host "Configuring settings..."
./configure-settings.ps1

# Determine the operating system
$osPlatform = [System.Environment]::OSVersion.Platform

if ($osPlatform -eq [System.PlatformID]::Unix -or $osPlatform -eq [System.PlatformID]::MacOSX) {
    # Linux or macOS
    $binPath = "$HOME/bin"
    if (-not (Test-Path -Path $binPath)) {
        New-Item -ItemType Directory -Path $binPath
    }

    Write-Host "Copying custom scripts to $binPath..."
    Copy-Item -Path ./scripts/*.ps1 -Destination $binPath -Force

    # Ensure ~/bin is in the PATH
    $profileContent += @"
# Add ~/bin to PATH if not already included
if (-not (\$env:PATH -contains "$binPath")) {
    [System.Environment]::SetEnvironmentVariable("PATH", "\$env:PATH;$binPath", [System.EnvironmentVariableTarget]::User)
}
"@
} elseif ($osPlatform -eq [System.PlatformID]::Win32NT) {
    # Windows
    $scriptsPath = "$HOME\Documents\WindowsPowerShell\Scripts"
    if (-not (Test-Path -Path $scriptsPath)) {
        New-Item -ItemType Directory -Path $scriptsPath
    }

    Write-Host "Copying custom scripts to $scriptsPath..."
    Copy-Item -Path ./scripts/*.ps1 -Destination $scriptsPath -Force

    # Ensure the scripts path is in the PATH
    $profileContent += @"
# Add $scriptsPath to PATH if not already included
if (-not (\$env:PATH -contains "$scriptsPath")) {
    [System.Environment]::SetEnvironmentVariable("PATH", "\$env:PATH;$scriptsPath", [System.EnvironmentVariableTarget]::User)
}
"@
}

# Write the updated profile content to the profile script
Set-Content -Path $profilePath -Value $profileContent

Write-Host "Custom scripts copied and PATH updated successfully!"

# Run additional scripts if needed
Write-Host "Running additional scripts..."
./script1.ps1
./script2.ps1

Write-Host "Setup complete! Please restart your PowerShell session to apply the profile settings."