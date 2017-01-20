using module ..\Packages.psm1

function Write-PackageList {

    try {
        [PackagesList]::GetInstance().Save()
    }
    catch {
        Throw "Unable to save list."
    }
}