$ModuleBase = $PSScriptRoot

Get-ChildItem -Path $PSScriptRoot\functions -filter *ps1 | 
    ForEach-Object -Process {
        . $_.FullName
    }