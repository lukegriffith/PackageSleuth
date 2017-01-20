<#
    .Description
    Initiates the AutoDownload process, performing the workflow on all configured packages in the json configuration file.

#>
function Invoke-AutoDownload {
    param(
        [switch]$disableExport
    )
    
    Write-Verbose "Initiating package autodownload."

    Write-Verbose "Importing package list from datastore."

    Import-PackageList

    Write-Verbose "Starting update workflow."

    Get-PackageList | Update-RecentVersion |  Sync-Packages

    if (-not $disableExport.Present) {
        Write-Verbose "Writing updates to datastore."
        Write-PackageList
    }

    

    Write-Verbose "Finish."

}