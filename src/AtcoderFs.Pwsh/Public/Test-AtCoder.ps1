function Test-AtCoder {
    param (
        $FolderPath = $pwd,
        [switch]$UseOJ = $false,
        $Runtime = "ubuntu.18.04-x64",
        $PublishFolder = "ojTest"
    )
    if ($UseOJ) {
        $proj = Get-Item $FolderPath/*.fsproj
        Set-Location $FolderPath
        dotnet publish -c Release -r $Runtime -o $PublishFolder --nologo
        oj t -c "$PublishFolder/$(Split-Path $FolderPath -Leaf)"
        Set-Location -
    } else {
        $proj = Get-Item $FolderPath/*.Tests/*.Tests.fsproj
        dotnet run --project $proj
    }
}
