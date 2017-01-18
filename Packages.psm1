using namespace System.Collections.Generic

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

        $items = $this.Document | Get-Content | ConvertFrom-Json
        # length needs to be obtained, as json array does not serialize correctly as list.
        # I need to obtain length, manually extract items and add to list.

        $item_count = $items.length

        For ($i = 0; $i -lt $item_count; $i++) {
            $Package = [Package]$items.Get($i)
            $this.Packages.Add($Package)
        }
    }

    # Constructor accepts FileInfo object, and loads items to packages list.
    PackagesList([System.IO.FileInfo]$Document) {

        $this.Document = $Document
        $this.Packages = [List[Package]]::new()
        $this.Load()
    }

}

class Package {

    [String]$Name 
    # Property used when stored to disk, can identify from superclass.
    [String]$Type
    [String]$Reference
    [String]$CurrentVersion
    [String]$RecentVersion

    [void]UpdateRecentVersion(){

        # Logic to find recent version
    }

    [void]UpdateCurrentVersion([string]$version){
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