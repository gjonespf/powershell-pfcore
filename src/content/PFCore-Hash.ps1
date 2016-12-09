<# 
 .Synopsis
  Merge to hashtables together. Note: Second hash overrides the first.

 .Description
  Merge to hashtables together. Note: Second hash overrides the first.

 .Example
   $a = @{"key1"="value1";"key2"="fred"}
   $b = @{"key1"="value2"}
   Merge-Hash $a $b
   #Should return key1=value2 & key2=fred
#>
function Merge-Hash ($a, $b) 
#TODO: Deprec in favour of Merge-Object?
{
   $ret = @{}
   $commonKeys = @($a.Keys | ?{ ($b.ContainsKey($_)) })
   # Add items to the hash where they don't exist in the first
   ($a.GetEnumerator() | ?{ $commonKeys -notcontains $_.Key } ) | % { $ret.Add($_.Name, $_.Value) }
   $ret += $b
   return $ret
}

Export-ModuleMember -function Merge-Hash
