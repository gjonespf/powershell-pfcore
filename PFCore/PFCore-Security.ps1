#($Directory, $Certificate, $Include)
function Invoke-SignChildren 
{
    Param(
       [Parameter(Position=0)]
       $Directory,
       [Parameter(Position=1)]
       $Certificate = $(throw "The parameter -Certificate is required."),
       [Parameter(Position=2)]
       $Include
    )

    Push-Location $PWD
    if(!$Directory)
    {
        $Directory = $PSScriptRoot
    }

    if(!$Include)
    {
        $Include = @("*.ps1","*.psm1","*.psd1","*.ps1xml")
    }

    $files = @(Get-ChildItem -Path "$Directory" -Include $Include -Recurse)
    foreach($file in $files)
    {
        $filePath = Resolve-Path $file.DirectoryName
        $fileIsInCurrentFolder = $filePath.ToString() -eq $PWD.ToString()
        if(-not $fileIsInCurrentFolder)
        {
            Set-Location $filePath
        }
        $fileSig = (Get-AuthenticodeSignature -FilePath $file)
        if($fileSig.Status -ne [System.Management.Automation.SignatureStatus]::Valid)
        {
            Write-Host -Foreground "Yellow" "File $file signature needs updating"
            Set-AuthenticodeSignature -FilePath $file -Certificate $Certificate
        }
        else
        {
            Write-Host -Foreground "Green" "File $file has a valid signature"
        }
    }

    Pop-Location
}
Export-ModuleMember -function Invoke-SignChildren
