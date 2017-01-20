using module ..\Packages.psm1
using module ..\Metadata.psm1


function Import-PackageList {

    [PackagesList]::SetInstance(
        (Get-Item -Path ($PSScriptRoot+"\..\" + [ModuleMetadata]::PackageConfig))
    )

}