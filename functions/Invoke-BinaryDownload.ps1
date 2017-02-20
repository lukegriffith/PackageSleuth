using namespace System.IO  
using module ..\Packages.psm1

<#
    .Description
    Downloads piped URL to a download location.
    Obtains file name from URL.

#>
function Invoke-BinaryDownload {
    param(
        [Parameter(ValueFromPipeline=$true)]
        [PSCustomObject]$Url,
        [string]$DownloadPath,
        [Package]$Package,
        [DownloadType]$type
    )

    Process {

        [uri]$uri = $Url.url
        [fileinfo]$file = $uri.segments[-1]

        if ($file.Extension -notin @('.exe','.msi','.msu')){
            Throw "Unable to determine file extension"
        }

        if ($Url.Type -eq "Url64"){
            $64Bit = ".x64"
        }

        $versionMap = @{[DownloadType]::Recent = $Package.RecentVersion; [DownloadType]::Current = $Package.CurrentVersion}

        $FilePath = "$DownloadPath\{0}-{1}{2}.{3}{4}" -f $Package.Reference, $Package.Name, $64Bit,
            $versionMap[$type], $file.Extension

        Invoke-WebCall -Uri $url.url -OutFile $FilePath
    }
}