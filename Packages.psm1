using namespace System.Collections.Generic
using module .\Metadata.psm1

<#
    .Description
    PackagesList is a collection of all packages configured for the auto downloader.
    This contains the methods to load and save any changes back to the document. 
#>
class PackagesList {

    [List[Package]]$Packages
    hidden [System.IO.FileInfo]$Document

    # Saves changes back to document.
    [void]Save(){
        $this.Packages | Convertto-json | Out-File -FilePath $this.Document.FullName
    }

    # Loads document items, and adds to list.
    [void]Load(){

        $items = Get-Content -Path $this.Document.FullName | ConvertFrom-Json

        $items.PSObject.Properties.Name | ForEach-Object {
            $Typename = $_

            $items.$TypeName | ForEach-Object {
                $this.Packages.Add(
                    (Merge-Object -PSCustomObject $_ -ExpectedType $TypeName)
                )
            }
            
        }
    }

    # Constructor accepts FileInfo object, and loads items to packages list.
    PackagesList([System.IO.FileInfo]$Document) {
        # Set document, initialize list and load. 
        $this.Document = $Document
        $this.Packages = [List[Package]]::new()
        $this.Load()
    }

}

<#
    .Description
    Package class is the superclass for packages that are added. This scaffolds out basic properties and has placeholders
    for UpdateRecentVersion() and Download() methods. 

#>
class Package {

    [String]$Name 
    # Property used when stored to disk, can identify from superclass.
    [String]$Reference
    [Version]$CurrentVersion
    [Version]$RecentVersion


    [void]UpdateCurrentVersion([Version]$version){
        $this.CurrentVersion = $version
    }

    [void]Download([String]$DownloadLocation){

    }

    Package(){
        $this.Type = $this.gettype()
    }


}

class ChocoPackage : Package { 

    [void]UpdateRecentVersion(){
    }
    [void]Download([string]$DownloadLocation){
    }
}

class NugetPackage : Package {

    [String]$Provider

    [void]UpdateRecentVersion(){
        
        $recentVersion = Read-NuGetPackageVersion -Provider $this.Provider -PackageID $this.Name |
            Sort-Object -Descending | Select-Object -First 1

        if (-not $recentVersion) {
            throw "Unable to obtain recent version from $($this.Provider), for $($this.Name)"
        }

        $this.RecentVersion = $recentVersion


    }

    [void]UpdateCurrentVersion(){
        
        if ($this.RecentVersion){
            $this.CurrentVersion = $this.RecentVersion
        }
        else {
            throw "No recent version set, to update current."
        }
       
    }

    [void]Download([string]$DownloadLocation){

        $downloadLoc = [ModuleMetadata]::DownloadLocation

        $package = Read-NuGetPackageData -Provider $this.Provider -PackageID $this.Name `
            -PackageVersion $this.CurrentVersion | Invoke-PackageDownload -downloadPath $downloadLoc

        $urls = Find-BinaryUrlFromNupkg -nupkg $package.fullname

        if (-not $urls) {
            throw "Unable to obtain binary URL's from nupkg"
        }

        $urls | Invoke-BinaryDownload -DownloadPath $downloadLoc -Package $this

    }
}