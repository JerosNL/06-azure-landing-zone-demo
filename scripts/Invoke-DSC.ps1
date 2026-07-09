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

Write-Host "Packaging DomainController DSC configuration..." -ForegroundColor Cyan

$dcStagingPath = "$env:TEMP\DomainControllerDSC"
if (Test-Path $dcStagingPath) { Remove-Item $dcStagingPath -Recurse -Force }
New-Item -ItemType Directory -Path $dcStagingPath | Out-Null

Copy-Item "$DscPath\DomainController.ps1" $dcStagingPath

$moduleBase = ($env:PSModulePath -split ';') | Where-Object { Test-Path $_ } | Select-Object -First 1

foreach ($module in $modules) {
    $modulePath = Get-Module -ListAvailable -Name $module | Select-Object -First 1 -ExpandProperty ModuleBase
    if ($modulePath) {
        $moduleParent = Split-Path $modulePath -Parent
        Copy-Item $moduleParent -Destination "$dcStagingPath\$module" -Recurse -Force
        Write-Host "  Bundled module: $module" -ForegroundColor Green
    }
    else {
        Write-Error "Module $module not found"
    }
}

$dcZipPath = "$OutputPath\DomainController.ps1.zip"
if (Test-Path $dcZipPath) { Remove-Item $dcZipPath -Force }
Compress-Archive -Path "$dcStagingPath\*" -DestinationPath $dcZipPath -Force
Write-Host "  Created DomainController.ps1.zip" -ForegroundColor Green

Write-Host "Packaging ManagementServer DSC configuration..." -ForegroundColor Cyan

$mgmtZipPath = "$OutputPath\ManagementServer.ps1.zip"
if (Test-Path $mgmtZipPath) { Remove-Item $mgmtZipPath -Force }
Compress-Archive -Path "$DscPath\ManagementServer.ps1" -DestinationPath $mgmtZipPath -Force
Write-Host "  Created ManagementServer.ps1.zip" -ForegroundColor Green

Write-Host "DSC packaging complete." -ForegroundColor Cyan
Write-Host "Commit the zip files in the dsc/ folder before running the pipeline." -ForegroundColor Yellow