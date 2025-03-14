# Install Oh My Posh

# Install Oh My Posh using PowerShellGet
Install-Module -Name oh-my-posh -Scope CurrentUser -Force -SkipPublisherCheck

# Import the module
Import-Module oh-my-posh

# Set up the prompt
Set-PoshPrompt -Theme ./configs/ohmyposh-config.json