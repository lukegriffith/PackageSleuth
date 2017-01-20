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
        [string]$Url,
        [string]$DownloadPath,
        [Package]$Package
    )

    Process {
        $uri = [uri]::TryCreate($url)
        [fileinfo]$file = $uri.segments[-1]

        if ($file.Extension -notin @('.exe','.msi','.msu')){
            Throw "Unable to determine file extension"
        }

        if ($Url.Type -eq "Url64"){
            $64Bit = ".x64"
        }

        $FilePath = "$DownloadPath\{0}-{1}{2}.{3}{4}" -f $Package.Reference, $Package.Name, $64Bit,
            $Package.Version, $file.Extension

        Invoke-WebRequest -Uri $url -OutFile $FilePath
    }
}