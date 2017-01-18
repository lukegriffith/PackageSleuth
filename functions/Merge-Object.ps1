using Module ../Packages
# This is not working on PowerShell Core. On Full PS 5.1 it works. 


function Merge-Object {
    param(
        # Custom object to translate to type.
        # Type needs to have a constructor with no parameters.
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [PSCustomObject]$PSCustomObject,
        # Type to merge object into.
        [Parameter(Mandatory=$true)]
        [String]$ExpectedType
    )
    Process {

        # Create Type
        $type = New-Object -Typename $ExpectedType

        # Iterate through each property of PSCustomObject
        $PSCustomObject.PSObject.Properties.Name | 
            ForEach-Object -Process { 
                # Check properties match, and only add if possible.
                if ($type.psobject.properties.name -contains $_) {
                    $type.$_ = $PSCustomObject.$_
                }
            }

        return $type
    }
}

function Test {
    return [ChocoPackage]::new()
}