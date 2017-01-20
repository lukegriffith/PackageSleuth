function Read-NuGetOdataFeed {
    param(
        $url,
        $PackageID
    )

    $urlStem = '{0}/api/v2/Packages()?$filter=id eq {1}&$orderby=Version desc'

    $url = $urlStem -f $url, $PackageID

    Invoke-RestMethod -uri $url 


}


    
