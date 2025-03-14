# Configure settings

# Set PowerShell settings
$profileSettings = Get-Content -Path ./configs/settings.json -Raw | ConvertFrom-Json

# Apply settings based on the operating system
if ($IsWindows) {
    # Apply settings for Windows
    $profileSettings | ForEach-Object {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\PowerShell\7" -Name $_.Name -Value $_.Value
    }
} elseif ($IsLinux) {
    # Apply settings for Linux
    $profileSettings | ForEach-Object {
        # Example: Set environment variables or other Linux-specific settings
        [System.Environment]::SetEnvironmentVariable($_.Name, $_.Value, [System.EnvironmentVariableTarget]::User)
    }
} else {
    Write-Host "Unsupported operating system."
}