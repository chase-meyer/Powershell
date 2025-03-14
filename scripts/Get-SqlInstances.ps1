param (
    [string[]]$servers,
    [switch]$Silent
)

# Determine the error action based on the $Silent parameter
if ($Silent) {
    $ErrorActionPreference = "SilentlyContinue"
}
else {
    $ErrorActionPreference = "Continue"
}

# Install the SqlServer module if not already installed
if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    Install-Module -Name SqlServer -Force -Scope CurrentUser -ErrorAction $ErrorActionPreference
}

# Import the SqlServer module
Import-Module SqlServer -ErrorAction $ErrorActionPreference

# Load the SMO assembly
Add-Type -AssemblyName "Microsoft.SqlServer.Smo" -ErrorAction $ErrorActionPreference

function Get-SqlInstances {
    param (
        [string]$server
    )
    $instances = @()
    $services = Invoke-Command -ComputerName $server -ScriptBlock { Get-Service | Where-Object { $_.DisplayName -like "SQL Server (*" } } -ErrorAction $ErrorActionPreference
    foreach ($service in $services) {
        $instanceName = $service.DisplayName -replace "SQL Server \(", "" -replace "\)", ""
        if ($instanceName -eq "MSSQLSERVER") {
            $instanceName = "."
            $instanceType = "Default"
        }
        else {
            $instanceName = ".\$instanceName"
            $instanceType = "Named"
        }
        $status = if ($service.Status -eq 'Running') { 'Running' } else { 'Stopped' }
        
        # Get SQL Server version and edition
        $version = ""
        $edition = ""
        if ($status -eq 'Running') {
            try {
                $serverConnection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection $instanceName
                $server = New-Object Microsoft.SqlServer.Management.Smo.Server $serverConnection
                $version = $server.Information.VersionString
                $edition = $server.EngineEdition
            }
            catch {
                $version = "Unknown"
                $edition = "Unknown"
            }
        }
        else {
            $version = "Not Running"
            $edition = "Not Running"
        }

        $instances += [PSCustomObject]@{ InstanceName = $instanceName; InstanceType = $instanceType; Status = $status; Version = $version; Edition = $edition }
    }
    return $instances
}

foreach ($server in $servers) {
    Write-Host "Processing server: $server"
    $sqlInstances = Get-SqlInstances -server $server
    $sqlInstances | Format-Table -Property InstanceName, InstanceType, Status, Version, Edition -AutoSize