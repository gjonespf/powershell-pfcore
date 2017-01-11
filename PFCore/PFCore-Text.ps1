
<# 
 .Synopsis
  Convert an array or flat text with columns to an object with properties matching the column names.

 .Description
  Convert an array or flat text with columns to an object with properties matching the column names.

 .Example
 Example:
 $data= @"
 	DRIVER              VOLUME NAME
 	local               004e9c5f2ecf96345297965d3f98e24f7a6a69f5c848096e81f3d5ba4cb60f1e
 	local               081211bd5d09c23f8ed60fe63386291a0cf452261b8be86fc154b431280c0c11
	local               112be82400a10456da2e721a07389f21b4e88744f64d9a1bd8ff2379f54a0d28
 	"@ 
 	$obj=Convert-TextColumnsToObject $data
 	$obj | ?{ $_."VOLUME NAME" -match "112be" }
#>
function Convert-TextColumnsToObject {
  param(
    [Parameter(Position=0)]
    $TableData = $(throw "The parameter -TableData is required."),
    $SplitLinesOn=[Environment]::NewLine
  )
# TODO: Include an option to mangle header names with spaces/special chars?

    if($TableData -is [array])  { 
        $data=$TableData 
    } else { 
        $data=$TableData.Split($SplitLinesOn)
    }
    $columnPreproc="\s{2,}"
    $headerString = $data | Select-Object -f 1
    #Preprocess to handle headings with spaces
    $headerElements = ($headerString -replace "$columnPreproc", "|") -split "\|" | Where-Object{$_}
    $headerIndexes = $headerElements | ForEach-Object{$headerString.IndexOf($_)}
    $results = $data | Select-Object -Skip 1  | ForEach-Object{
        $props = @{}
        $line = $_
        For($indexStep = 0; $indexStep -le $headerIndexes.Count - 1; $indexStep++){
            $value = $null            # Assume a null value 
            $valueLength = $headerIndexes[$indexStep + 1] - $headerIndexes[$indexStep]
            $valueStart = $headerIndexes[$indexStep]
            If(($valueLength -gt 0) -and (($valueStart + $valueLength) -lt $line.Length)){
                $value = ($line.Substring($valueStart,$valueLength)).Trim()
            } ElseIf ($valueStart -lt $line.Length){
                $value = ($line.Substring($valueStart)).Trim()
            }
            $props.($headerElements[$indexStep]) = $value    
        }
        [pscustomobject]$props
    }

    return $results
} 

Export-ModuleMember -function Convert-TextColumnsToObject
