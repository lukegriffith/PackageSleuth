using module ..\Packages.psm1

<#
    .Description
    Returns instance of Packages list.

    .Example
    PS> Get-PackagesList

#>
function Get-PackageList {

    $pkgs = [PackagesList]::GetInstance().Packages

    if (-not $pkgs) {
        Throw "No packages defined in config file."
    }

    return $pkgs
}