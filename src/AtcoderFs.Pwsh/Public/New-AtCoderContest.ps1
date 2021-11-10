function New-AtCoderContest {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        $contestId
    )
    acc new $contestId


    $taskFolders = Get-ChildItem $contestId -Directory
    $parent = $taskFolders[0].Parent

    # init sln
    dotnet new sln -o $parent
    Set-Location $parent

    # inti tasks
    $taskFolders | ForEach-Object {
        dotnet new acctask -o $_.Name
        $fsprojPath = Resolve-Path "$($_.Name)/$($_.Name).fsproj"
        dotnet sln add $fsprojPath
    }

    # init test
    dotnet new acctest -o "$($parent.Name).Tests"
    $testProjPath = Resolve-Path "$($parent.Name).Tests/$($parent.Name).Tests.fsproj"
    dotnet sln add $testProjPath
    # add test ref
    $taskFolders | ForEach-Object {
        $fsprojPath = Resolve-Path "$($_.Name)/$($_.Name).fsproj"

        dotnet add $testProjPath reference $fsprojPath
    }
    New-TestCode (Get-AtCoderTasksInfo $contestId) -Confirm:$false | Add-Content "$(Split-Path $testProjPath)/Tests.fs"

    paket add Expecto --project $testProjPath

    dotnet build
    Set-Location -
}
