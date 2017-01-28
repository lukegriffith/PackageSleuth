using module ..\Packages.psm1

<#
    .Description
    Invokes a package download of the defined packages in the json config.

    .Example
    Invoke-PackageDownload

#>


function Update-RecentVersion {
    param(
        [Parameter(ValueFromPipeline=$true)]
        [Package]$Package
    )

    Process {

        Write-Verbose "Updating version for $($Package.Name)"

        try {
            $Package.UpdateRecentVersion()
        }
        catch {
            Write-Warning "Unable to update recent version for $($Package.Name)"
        }

        Write-Output $Package
    }
}

function Sync-Packages {
    param(
        [Parameter(ValueFromPipeline=$true)]
        [Package]$Package
    )

    Process {

        Write-Verbose "Starting sync for $($Package.Name)"

        if ([Version]$Package.CurrentVersion -lt [Version]$Package.RecentVersion) {

            Write-Verbose "Initiating download for $($Package.Name)"
            try {
                $Package.Download()

                Write-Verbose "Download completed for $($Package.Name)"

                $Package.UpdateCurrentVersion()

                Write-Verbose "Version updated for $($Package.Name)"
            }
            catch {

                Write-Warning "Unable to download package for $($Package.Name)"
                Write-Error $_

            }

        }
        else {

        }

        Write-Output $Package

    }
}
