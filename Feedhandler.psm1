using module .\Packages.psm1

class UpdateFeed {

    [String]$FeedType
    [String]$Feed

    [Package[]]GetFeed() {
        return @([Package]::new())
    }

    [bool]PackageExists() {

        return $false
    }

    [Package]GetPackage() {

        return [Package]::new()
    }
}


class RssFeed : UpdateFeed {


    [Package[]]GetFeed(){

        
    }

}


class ChocoFeed : UpdateFeed {
    
}