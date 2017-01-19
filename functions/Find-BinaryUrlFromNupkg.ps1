
function ParseVariable {
    param(
        $ast,
        $varPath
    )



    $Variable = $ast | Where-Object {$_.VariablePath.UserPath -eq $varPath -and  $_.Parent.Operator -eq "Equals"}

    $Variable.parent.right.expression.value


}



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

            # Obtain index of url/url64bit parameters name
            $index = $Function.CommandElements.IndexOf($_) 

            # take incremented index, as this will be the parameter value
            $URL = $Function.CommandElements[$index+1]

            # If parameter is a VariableExpressionAST, variables needs to be parsed.
            if ($URL -is [System.Management.Automation.Language.VariableExpressionAst]) {
                # Variable needs to be parsed
                $urls += ParseVariable -Ast $allVar -varPath $URL.VariablePath.UserPath
            }
            else {
                # URL found.
                $urls += $URL.Value
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

                        $urls += ParseVariable -Ast $allVar -varPath $url.VariablePath
                    }
                    else {
                        $urls += $url.value
                    }

                    if ($url64bit -and $url64bit -is [System.Management.Automation.Language.VariableExpressionAst]) {

                        $urls +=ParseVariable -Ast $allVar -varPath $url64bit.VariablePath
                    }
                    else {
                        $urls += $url64bit.value
                    }


                }
            }
        }

    }


    Write-Output $urls

}


function Find-BinaryUrlFromNupkg {

    param(
        [String]$nupkg
    )


}