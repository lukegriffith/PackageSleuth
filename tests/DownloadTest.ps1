


Import-Module ..\AutoDownloader.psd1

$PackageName = "GoogleChrome"
$CurrentVersion = [Version]("10.0.0")

Read-NuGetPackageVersion -PackageID $PackageName | 
    Where-Object {$_}