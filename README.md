# AutoDownloader (Working Title)

## Setup
Using the PackageConfig.json file you can configure what you want to automatically download
if a new version is release. Here is a basic example:

```json
{
    "NugetPackage":  [
        {
            "Provider":  "www.chocolatey.org",
            "Name":  "GoogleChrome",
            "Reference":  "TempRef",
            "Version":  "1.0.0",
            "RecentVersion":  "56.0.2924.76"
        }
    ],
    "PSGallery":  [
        {
            "Name":  "Pester",
            "Reference":  "TempRef",
            "Version":  "4.0.2",
            "RecentVersion":  "4.0.2"
        }
    ]
}

```

To start the process to check for updates and download the latest package do:

```powershell
Import-Module AutoDownloader
Invoke-AutoDownload
```