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

        try {
            $Package.Download()
            $Package.UpdateCurrentVersion()
        }
        catch {
            Write-Warning "Unable to download package for $($Package.Name)"
        }

        Write-Output $Package
    }
}
