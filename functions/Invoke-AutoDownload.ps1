<#
    .Description
    Initiates the AutoDownload process, performing the workflow on all configured packages in the json configuration file.

#>
function Invoke-AutoDownload {
    
    Write-Verbose "Initiating package autodownload."

    Write-Verbose "Importing package list from datastore."

    Import-PackageList

    Write-Verbose "Starting update workflow."

    Get-PackagesList | Update-RecentVersion | Where-Object {
        -not $_.CurrentVersion -or ([Version]$_.RecentVersion -gt [Version]$_.CurrentVersion)
        } | Sync-Packages

    Write-Verbose "Writing updates to datastore."

    Write-PackageList

    Write-Verbose "Finish."

}