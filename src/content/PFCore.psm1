#Load ps1 scripts in current dir
gci $psscriptroot\PFCore-*.ps1 | % { . $_.FullName }
