function Resolve-DotnetTool {
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [string]$PackageID
    )
    $localToolMatching = dotnet tool list | Select-String "^$PackageID(?=\s)" -Quiet
    if ($localToolMatching) {
        # Create Function 
        $null = New-Item -Force -Path function: -Name "script:$PackageID" -Value @"
        [CmdletBinding()]
        param(
            [Parameter(Position=1, ValueFromRemainingArguments)]
            [string[]]`$additionalArgs
        )

        @('dotnet', '$PackageID') + `$additionalArgs
        | Join-String -Separator ' '
        | Invoke-Expression
"@
    } else {
        # Check command
        $null = Get-Command $PackageID
    }
}