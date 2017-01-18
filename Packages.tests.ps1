using Namespace System.IO
using Module .\Packages.psm1

Import-Module .\AutoDownloader.psm1

Describe "Testing PackagesList class" {

    $mockedFileInfo = [FileInfo]::new("/Mocked.json")
    Mock Get-Content {
        return @"
{
    "ChocoPackage": [
        {
            "Name" : "GoogleChrome",
            "CurrentVersion" : null
        }
    ],
    "FeedPackage" : [
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

