using Namespace System.IO
using Module ..\Packages.psm1

Import-Module ..\AutoDownloader.psm1

Describe "Testing PackagesList class" {

    $mockedFileInfo = [FileInfo]::new("/Mocked.json")
    Mock Get-Content {
        return @"
{
    "NugetPackage": [
        {
            "Name" : "GoogleChrome",
            "CurrentVersion" : null
        }
    ],
    "PSGallery" : [
        {
            "Name" : "FireFox",
            "CurrentVersion" : null
        }
    ]
}
"@
    } -ModuleName Packages

    $PackagesList = [PackagesList]::new($mockedFileInfo)
    

    it "Should contain 1 package" {
        $PackagesList.Packages.Count | should be 2
    } 

}

Describe "Packages" {

    Context "Testing outdated logic" {

        $package = [Package]::new()

        it "Should return boolean" {
            $package.IsOutdated() | should BeOfType [bool]
        }

        $package.Version = "1.0"
        $package.RecentVersion = "1.1"

        it "Should return true, as recent is higher" {
            $package.IsOutdated() | should be $true
        }

        $package.RecentVersion = "1.0"
        it "Should return false, as recent is same" {
            $package.IsOutdated() | should be $false
        }

    }
}

