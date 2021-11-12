function Get-DotnetToolClosure {
    [OutputType([scriptblock])]
    param (
        [Parameter(Mandatory)]
        [string]$PackageID
    )
    $localToolMatching = dotnet tool list | Select-String "^$PackageID(?=\s)" -Quiet
    if ($localToolMatching) {
        { Start-Process dotnet (@($PackageID) + $args) }.GetNewClosure()
    } elseif (Get-Command $PackageID) {
        { Start-Process $PackageID $args }.GetNewClosure()
    }
}