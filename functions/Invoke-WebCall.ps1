


<#
    .Description
    Used to abstract out Invoke-RestMethod, this is due to proxy requierments.
    Allows for a central place to configure switches, and pass through arguments. 


#>
function Invoke-WebCall {
    param(
        [string]$uri,
        [string]$OutFile
    )

    Write-Verbose "Calling $uri"

    Invoke-RestMethod @PSBoundParameters

}