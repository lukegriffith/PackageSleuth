using Namespace System.IO
using Module .\Packages.psm1

Describe "Testing PackagesList class" {

    $mockedFileInfo = [FileInfo]::new("C:\Mocked.json")
    Mock Get-Content {
        return @"
{
    "ChocoPackage": [
        {
            "Name" : "GoogleChrome",
            "Version" : null,
        }
    ],
    "FeedPackage" : null
}
"@
    }

    it "Should created PackagesList from mocked document"{
        $PackagesList = [PackagesList]::new($mockedFileInfo)
    }



}

