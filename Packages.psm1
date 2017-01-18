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

}