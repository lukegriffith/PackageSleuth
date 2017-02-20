using namespace System.Collections.Generic
using module PackageManagement
using module .\Metadata.psm1

enum DownloadType {
    Recent 
    Current
}


<#
    .DESCRIPTION
    PackagesList is a collection of all packages configured for the auto downloader.
    This contains the methods to load and save any changes back to the document. 
#>
class PackagesList {

    [List[Package]]$Packages
    
    hidden [System.IO.FileInfo]$Document

    static hidden [PackagesList]$Instance

    # Saves changes back to document.
    [void]Save(){
    
        $obj = [PSCustomObject]@{}

        # Determining types of objects to build JSON config list.
        $groupedTypes = $this.Packages | Select-Object @{name="Type";expression={$_.GetType().Name}} | 
            Group-Object -Property Type

        # Initializing packages list for each type.
        $groupedTypes | ForEach-Object -Process {
            $obj | Add-Member -Name $_.Name -Value ([List[Package]]::new()) -MemberType NoteProperty
        }

        # Appending packages to the correct list.
        $this.Packages | ForEach-Object { 
            $Type = $_.GetType().Name
            $obj.$Type.Add($_)
        }

        # Export packages
        $obj | Convertto-json | Out-File -FilePath $this.Document.FullName
    }

    # Loads document items, and adds to list.
    [void]Load(){

        $items = Get-Content -Path $this.Document.FullName | ConvertFrom-Json

        $items.PSObject.Properties.Name | ForEach-Object {
            $Typename = $_

            $items.$TypeName | ForEach-Object {

                $obj = $_
                $this.Packages.Add(
                    (Merge-Object -PSCustomObject $_ -ExpectedType $TypeName)
                )
            }
            
        }
    }


    static [PackagesList]GetInstance() {

        if (-not [PackagesList]::Instance) {
            throw "No instance found"
        }

        return [PackagesList]::Instance
    }

    static [void]SetInstance([PackagesList]$List) {
        [PackagesList]::Instance = $List
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
    .DESCRIPTION
    Package class is the superclass for packages that are added. This scaffolds out basic properties and has placeholders
    for UpdateRecentVersion() and Download() methods. 

#>
class Package {

    [String]$Name 
    # Property used when stored to disk, can identify from superclass.
    [String]$Reference
    [String]$Version
    [String]$RecentVersion


    [void]UpdateVersion([String]$version){
        $this.Version = $version
    }

    [void]Download([DownloadType]$Type){

    }

    [bool]IsOutdated(){
        return ([version]$this.RecentVersion -gt [version]$this.Version)
    }
    

}

class ChocoPackage : Package { 

    [void]UpdateRecentVersion(){
    }
    [void]Download([DownloadType]$Type){
    }
}

class PSGallery : Package { 

    [void]UpdateRecentVersion(){
        Try {
            $Module = Find-Module -Name $this.Name
            $Version = [Version]::Parse($Module.Version)

            If ($Version -ne $this.RecentVersion) {
                $this.RecentVersion = $Version
            }
        }
        Catch {
            throw "Unable to obtain recent version for $($this.Name)"
        }
    }

    [void]UpdateCurrentVersion(){
        if ($this.RecentVersion){
            $this.Version = $this.RecentVersion
        }
        else {
            throw "No recent version set, to update current."
        }
    }

    [void]Download(){
        
        $downloadLoc = [ModuleMetadata]::DownloadLocation
        
        Try {
            Save-Module -Name $this.Name -Path $downloadLoc
        }
        Catch {
            throw "Unable to download $($this.Name). $($_.Exception.Message)"
        }
    }
}

class NugetPackage : Package {

    [String]$Provider

    [void]UpdateRecentVersion(){
        
        $versionList = Read-NuGetPackageVersion -Provider $this.Provider -PackageID $this.Name 
        $recentVersion = $versionList | Select-Object -Last 1

        # Throw if version cannot be determined.
        if (-not $recentVersion) {
            throw "Unable to obtain recent version from $($this.Provider), for $($this.Name)"
        }

        # Attempt version parse
        [version]$version = "0.0.0.0"
        [version]::TryParse($recentVersion, [ref]$version)

        # Set recent version
        if ($version -ne [version]"0.0.0.0") {
            $this.RecentVersion = $recentVersion
        }
    }

    [void]UpdateVersion(){
        
        if ($this.RecentVersion){
            $this.Version = $this.RecentVersion
        }
        else {
            throw "No recent version set, to update current."
        }
       
    }

    [void]Download([DownloadType]$Type){

        $downloadLoc = [ModuleMetadata]::DownloadLocation

        $version = $this.RecentVersion

        if ($Type -eq [DownloadType]::Current){
            $version = $this.Version
        }

        $package = Read-NuGetPackageData -Provider $this.Provider -PackageID $this.Name `
            -PackageVersion $version | Invoke-PackageDownload -downloadPath $downloadLoc

        $urls = Find-BinaryUrlFromNupkg -nupkg $package.fullname

        if (-not $urls) {
            throw "Unable to obtain binary URL's from nupkg"
        }

        $urls | Invoke-BinaryDownload -DownloadPath $downloadLoc -Package $this -type $Type

    }

}