using module ..\Metadata.psm1

<#
    .synopsis
    Find-BinaryURLFromNupkg obtains the download URL provided in the package. 

    .description
    Ties together a number of cmdlets that extract a local nupkg, and attmepts to locate the definition of the url / url64bit paramter provided 
    to the Install-Chocolatey* cmdlets. This will return an array of URL's.

    .notes
    Author: Luke Griffith
    Date: 20/01/17

#>
function Find-BinaryUrlFromNupkg {
    [cmdletbinding()]
    param(
        [String]$nupkg
    )

    Begin {

        $extractPath = [ModuleMetadata]::CacheLocation

        if (-not $extractPath) {
            New-Item -ItemType Directory -Path $extractPath
        }

        if (-not (test-path $nupkg)) {
            Throw "Unable to locate nupkg."
        }
    }

    Process {


        $nupkgItem = Get-Item -Path $nupkg
        $baseName = $nupkgItem.baseName
        $UncompressedArchive = "$extractPath\$baseName"

        Expand-Archive -Path $nupkgItem.fullname -DestinationPath $UncompressedArchive

        $InstallScript = Get-ChildItem $UncompressedArchive -Filter "ChocolateyInstall.ps1" -Recurse

        ParseScriptForUrl -ScriptFile $InstallScript.FullName

    }

    End {

        Remove-Item $extractPath -force -Recurse
    }


}


<#
    .Description
    Takes a AST object, and attempts to obtain the root variable of the given variable path. 

#>
function ParseVariable {
    param(
        $ast,
        $varPath
    )
    
    $variable = $ast | Where-Object {$_.VariablePath.UserPath -eq $varPath -and  $_.Parent.Operator -eq "Equals"}
    return $variable.parent.right.expression.value
}


<#
    .Description
    Given a PS1 script, it will inspect the syntax tree and attempt to pull out the URL or URL64BIT url provided to the 
    Install-Chocolatey* cmdlet. 

    .Notes
    I've tried to comment as much as possible as the AST stuff gets complicated real fast. 

#>
function ParseScriptForUrl {

    param(
        $ScriptFile
    )

    $text = Get-Content $ScriptFile -raw
    $ScriptBlock = [scriptblock]::Create($text)

    # Extract all functions from script block.
    $allFunctions = $ScriptBlock.Ast.FindAll({param($ast) $ast -is [System.Management.Automation.Language.CommandAst]}, $true)

    # Extract variables from script block
    $allVar = $ScriptBlock.Ast.FindAll({param($ast) $ast -is [System.Management.Automation.Language.VariableExpressionAst]}, $true)

    $urls = @()

    $Found = $false

    # Find choco install function and process 
    $allFunctions | ? {$_.extent -like "Install-Chocolatey*"} | ForEach-Object -Process {

        $Function = $_

        # Loop through elements and try to find -url and -url64bit params
        $_.CommandElements | Where-Object {$_.Extent -in @("-Url", "-Url64bit")} | ForEach-Object { 

            $Found = $true

            switch -exact ($_.Extent){
                "-Url" { $UrlType = "Url"}
                "-Url64bit" { $UrlType = "Url64"}
            }

            # Obtain index of url/url64bit parameters name
            $index = $Function.CommandElements.IndexOf($_) 

            # take incremented index, as this will be the parameter value
            $URL = $Function.CommandElements[$index+1]

            # If parameter is a VariableExpressionAST, variables needs to be parsed.
            if ($URL -is [System.Management.Automation.Language.VariableExpressionAst]) {
                # Variable needs to be parsed
                $urls += [pscustomobject]@{
                    Url = (ParseVariable -Ast $allVar -varPath $URL.VariablePath.UserPath);
                    Type = $UrlType
                }
            }
            else {
                # URL found.
                $urls += [pscustomobject]@{ Url = $URL.Value; Type = $UrlType }
            }

        } -End {

            # if url not found, attempt to parse for splat param
            if ($Found -eq $false) {


                # search for a splatted parameter
                $Function.CommandElements | Where-Object {$_.Extent -match "^@(?<splatVar>.+$)"} | out-null


                # Look up variable, should return 2 - the time its declared and the time its splatted
                $ParamSplat = $allVar | Where-Object {$_.VariablePath.UserPath -eq $Matches.splatVar}


                # check to ensure the variable is splatted
                if ($ParamSplat | Where-Object {$_.Splatted}) {

                    # locate the non splatted declaration
                    $splat = $ParamSplat | Where-Object {!$_.Splatted} 

                    # Extract values
                    $url = $splat.parent.Right.Expression.KeyValuePairs.Where{$_.Item1.value -eq "url"}.Item2.PipelineElements.Expression
                    $url64bit = $splat.parent.Right.Expression.KeyValuePairs.Where{$_.Item1.value -eq "url64bit"}.Item2.PipelineElements.Expression

                    # if begins with dollar, means it is a variable and we need to find the variable
                    if ($url -and $url -is [System.Management.Automation.Language.VariableExpressionAst]) {

                        $urls += [pscustomobject]@{
                            Url = (ParseVariable -Ast $allVar -varPath $url.VariablePath);
                            Type = "Url"
                        }
                    }
                    else {
                        $urls += [pscustomobject]@{Url = $url.value; Type = "Url" }
                    }

                    if ($url64bit -and $url64bit -is [System.Management.Automation.Language.VariableExpressionAst]) {

                        $urls += [pscustomobject]@{ 
                            Url = (ParseVariable -Ast $allVar -varPath $url64bit.VariablePath)
                            Type = "Url64"
                        }
                    }
                    else {
                        $urls += [pscustomobject]@{ Url = $url64bit.value; Type = "Url64" } 
                    }
                    


                }
            }
        }

    }


    if ($urls.Count -eq 0) {

        $urlVariable = $allVar | Where-Object {$_.VariablePath.UserPath -like "*url*"} | ForEach-Object -Process {

            $variable = $_ | Where-Object {$_.Parent.Operator -eq "Equals"}

            if ($variable) { 

                $variablel.VariablePath.UserPath -match "(32|64)"

                if ($Matches.1 -eq "32") {
                    $UrlType = $url
                }
                elseif ($Matches.1 -eq "64") {

                    $UrlType = "Url64"
                }

                $urls += [pscustomobject]@{
                    Url = ($variable.parent.right.expression.value);
                    Type = $UrlType
                }

            }

        }


    }


    Write-Output $urls

}

