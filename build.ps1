# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

#PSDepend
Install-Module PSDepend
Import-Module PSDepend
Invoke-PSDepend -Path .\requirements.psd1 -Force -Install -Import

Set-BuildEnvironment

Invoke-psake .\build\psake.ps1
exit ( [int]( -not $psake.build_success ) )