<#
.SYNOPSIS
    Packages DSC configurations for use with the Azure VM DSC extension.

.DESCRIPTION
    This script installs required DSC modules, compiles the DSC configurations
    and packages them as zip files for upload to the repository.
    Run this script locally before pushing changes to the repository.

.NOTES
    Requires: PowerShell 5.1 or higher
              Az PowerShell module
              Administrator privileges for module installation
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]$DscPath = "$PSScriptRoot\..\dsc",

    [Parameter()]
    [string]$OutputPath = "$PSScriptRoot\..\dsc"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "Installing required DSC modules..." -ForegroundColor Cyan

$modules = @(
    'ActiveDirectoryDsc',
    'NetworkingDsc'
)

foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "  Installing $module..." -ForegroundColor Yellow
        Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
    }
    else {
        Write-Host "  $module already installed" -ForegroundColor Green
    }
}

Write-Host "Packaging DSC configurations..." -ForegroundColor Cyan

$configurations = @(
    @{
        Script   = 'DomainController.ps1'
        ZipName  = 'DomainController.ps1.zip'
    },
    @{
        Script   = 'ManagementServer.ps1'
        ZipName  = 'ManagementServer.ps1.zip'
    }
)

foreach ($config in $configurations) {
    $scriptPath = Join-Path $DscPath $config.Script
    $zipPath    = Join-Path $OutputPath $config.ZipName

    if (-not (Test-Path $scriptPath)) {
        Write-Error "DSC script not found: $scriptPath"
        continue
    }

    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }

    Write-Host "  Packaging $($config.Script)..." -ForegroundColor Yellow

    Compress-Archive -Path $scriptPath -DestinationPath $zipPath -Force

    Write-Host "  Created $($config.ZipName)" -ForegroundColor Green
}

Write-Host "DSC packaging complete." -ForegroundColor Cyan
Write-Host "Commit the zip files in the dsc/ folder before running the pipeline." -ForegroundColor Yellow