<# 
 .Synopsis
  Get a list of path segments from the top to the root folder.

 .Description
  Get a list of path segments from the top to the root folder.

 .Example
   Get-ParentPathSegments "c:\windows\system32"
   #Should return 
   # c:\windows\system32
   # c:\windows
   # c:
#>
function Get-ParentPathSegments
{
    Param
    (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        $Path=$PSScriptRoot
    )

    $Item = Get-Item -Path $Path
    if ($Item.FullName -ne $Item.Root.FullName)
    {
        $Item.FullName
        Get-ParentPathSegments -Path $Item.Parent.FullName
    }
    else
    {
        $Item.FullName
    }
}
Export-ModuleMember -function Get-ParentPathSegments

#TODO: Perf, and why?
<# 
 .Synopsis
  Get a list of directories & subdirectories matching the search criteria.

 .Description
  Get a list of directories & subdirectories matching the search criteria.

 .Example
   TODO: Fill this in
#>
function Find-ChildDirectories {
    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]$Paths=$PSScriptRoot,
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false
        )]
        [string[]]$Excludes="",
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false
        )]
        [string[]]$ExcludeDirs="",
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]$Includes=""
    )

    $excludedPaths = @()
    $pathsToSearch = @()
    $pathsToSearch = $pathsToSearch + @(Resolve-Path $Paths | Get-Item)
    $pathsToSearch = $pathsToSearch + @(Get-ChildItem $Paths -Directory | ForEach-Object { 
    #$pathsToSearch = Get-ChildItem $Paths -Recurse -Directory | ForEach-Object { 
            $allowed = $true
            $searchPath = $_
            #$parentPathExcluded = (Get-ParentPath $searchPath.FullName | Where-Object { $ExcludeDirs -contains ($_ | Split-Path -Leaf) }) 
            $parentPathExcluded = (@($searchPath.FullName) | Where-Object { $ExcludeDirs -contains ($_ | Split-Path -Leaf) }) 
            if($parentPathExcluded)
            {
                #if($excludedPaths -notcontains $parentPathExcluded) {
                    $excludedPaths = $excludedPaths + @($parentPathExcluded)
                #}
                $allowed = $false
            }
            if ($allowed) {
                $searchPath
                Find-ChildDirectories -Paths "$($searchPath.FullName)" -Excludes $Excludes -ExcludeDirs $ExcludeDirs -Includes $Includes
            }
    })
    Write-Verbose "PathsToSearch: $($pathsToSearch.Count) Excluded: $($excludedPaths.Count)"
    return ($pathsToSearch | Select-Object -Unique)
}
Export-ModuleMember -function Find-ChildDirectories

#TODO: Perf, and why?
<# 
 .Synopsis
  Get a list of files from the specified paths matching the search criteria.

 .Description
  Get a list of files from the specified paths matching the search criteria.

 .Example
   TODO: Fill this in
#>
function Find-ChildItems {
    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]$Paths=$PSScriptRoot,
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false
        )]
        [string[]]$Excludes="",
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false
        )]
        [string[]]$ExcludeDirs="",
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]$Includes=""
    )

    Write-Verbose "Searching paths for valid dirs: '$($Paths)' excluding '$($ExcludeDirs)' "
    $pathsToSearch = Find-ChildDirectories -Paths $Paths -ExcludeDirs $ExcludeDirs
    $files = $pathsToSearch | Foreach-Object { $path = $_.FullName; $Includes | Foreach-Object { Get-ChildItem (Join-Path $path $_) -Exclude $Excludes } }
    return ($files | Select-Object -Unique)
}
Export-ModuleMember -function Find-ChildItems

