<# 
 .Synopsis
  Implement a Using / IDisposable statement from C# in PowerShell.

 .Description
  Implement a Using / IDisposable statement from C# in PowerShell.
   http://weblogs.asp.net/adweigert/powershell-adding-the-using-statement

 .Example
   # Short example ... 
   Using ($user = $sr.GetDirectoryEntry()) { 
     $user.displayName = $displayName 
     $user.SetInfo() 
   } 
#>
function Use-Object {
    param (
        [System.IDisposable] $inputObject = $(throw "The parameter -inputObject is required."),
        [ScriptBlock] $scriptBlock = $(throw "The parameter -scriptBlock is required.")
    )
    
    Try {
        &$scriptBlock
    } Finally {
        if ($inputObject -ne $null) {
            if ($inputObject.psbase -eq $null) {
                $inputObject.Dispose()
            } else {
                $inputObject.psbase.Dispose()
            }
        }
    }
}

<# 
 .Synopsis
  Join the properties of two objects together.

 .Description
  Join the properties of two objects together.

 .Example
   $obj1 = @{"key1"="value1"}
   $obj2 = @{"key1"="value2"}
   Join-Object $obj1 $obj2
#>
function Join-Object {
    #TODO: Deprec for merge? No overwriting?
    Param(
       [Parameter(Position=0)]
       $First
    ,
       [Parameter(Position=1,ValueFromPipeline=$true)]
       $Second
    )
    BEGIN {
       [string[]] $p1 = $First | gm -type Properties | select -expand Name
    }
    Process {
       $Output = $First | Select $p1
       foreach($p in $Second | gm -type Properties | Where { $p1 -notcontains $_.Name } | select -expand Name) {
          Add-Member -in $Output -type NoteProperty -name $p -value $Second."$p"
       }
       $Output
    }
 }

<# 
 .Synopsis
  Merge the properties of two objects together, overwriting properties on the first object.

 .Description
  Merge the properties of two objects together, overwriting properties on the first object. Is recursive, and will copy sub objects.

 .Example
   $obj1 = @{"key1"="value1"}
   $obj2 = @{"key1"="value2"}
   Merge-Object $obj1 $obj2
#>
function Merge-Object {
  param(
    [Parameter(Position=0)]
    $Base,
    [Parameter(Position=1)]
    $Additional
  )

    $propNames = $($Additional | Get-Member -MemberType *Property).Name
    foreach ($propName in $propNames) {
        if ($Base.PSObject.Properties.Match($propName).Count) {
            if ($Base.$propName.GetType().Name -eq "PSCustomObject")
            {
                $Base.$propName = Merge-Object $Base.$propName $Additional.$propName
            }
            else
            {
                $Base.$propName = $Additional.$propName
            }
        }
        else
        {
            $Base | Add-Member -MemberType NoteProperty -Name $propName -Value $Additional.$propName
        }
    }
    return $Base
}

Export-ModuleMember -function Merge-Object
Export-ModuleMember -function Join-Object
Export-ModuleMember -function Use-Object
