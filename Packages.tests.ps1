using Namespace System.IO
using Module .\Packages.psm1

Describe "Testing PackagesList class" {

    $mockedFileInfo = [FileInfo]::new("C:/Mocked.json")
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
    } -ModuleName Packages

    $PackagesList = [PackagesList]::new($mockedFileInfo)
    

    it "Should contain 1 package" {
        $PackagesList.Packages.Count | should be 1
    } 

}

