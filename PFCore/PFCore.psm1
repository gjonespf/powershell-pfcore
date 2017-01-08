#Load ps1 scripts in current dir
Get-ChildItem $psscriptroot\PFCore-*.ps1 | ForEach-Object { . $_.FullName }
