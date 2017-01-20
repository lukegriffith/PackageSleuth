using module ..\Packages.psm1
using module ..\..\AutoDownloader


$config = Get-Content $PSScriptRoot\..\PackagesConfig.json | ConvertFrom-Json

$config.NugetPackages | ForEach-Object {

    [NuGetPackage]$Package = $_ 

    $Package.UpdateRecentVersion()

    try {
        $Package.UpdateCurrentVersion()
    }
    catch {
        Write-Warning "New version not found"
    }

    $Package.download()



}




