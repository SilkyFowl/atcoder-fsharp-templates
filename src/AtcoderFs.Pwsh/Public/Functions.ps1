function Enter-AtCoderOnlineJudge {
    oj login https://beta.atcoder.jp/
}
function Enter-AtCoderCli {
    acc login
}

function Get-AtCoderContestInfo {
    Get-Content contest.acc.json | ConvertFrom-Json
}

function New-AtCoderContest {
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
    New-TestCode (Get-AtCoderTasksInfo $contestId) | Add-Content "$(Split-Path $testProjPath)/Tests.fs" 
    
    # init paket
    paket init
    dotnet new accpacket --force
    paket add Expecto --project $testProjPath
    
    dotnet build
    Set-Location -
}

function Get-AtCoderTasksInfo {
    param (
        [Parameter(Mandatory)]
        $contestId
    )
    Import-Module AngleParse
    $res = Invoke-RestMethod https://atcoder.jp/contests/$contestId/tasks
    [pscustomobject]@{
        contestId = $contestId
        tasks     = $res | Select-HtmlContent "#main-container > div.row > div:nth-child(2) > div > table > tbody > tr", @{
            Label   = "td:nth-child(1)"
            Title   = "td:nth-child(2)"
            Timeout = "td:nth-child(3)", ([regex]'(\S{1,})')
            Memory  = "td:nth-child(4)", ([regex]'(\S{1,})')
        }
    }

}

function New-TestCode {
    param (
        [Parameter(Mandatory)]
        $info
    )
    $info.tasks | ForEach-Object {
        $ExecutionContext.InvokeCommand.ExpandString($Script:TemplateTestType)
    }
    $ExecutionContext.InvokeCommand.ExpandString($Script:TemplateTestListHeader)
    $info.tasks | ForEach-Object {
        $ExecutionContext.InvokeCommand.ExpandString($Script:TemplateTestFunction)
    }
    $ExecutionContext.InvokeCommand.ExpandString($Script:TemplateTestListFooter)
}


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
function Update-AtCoderDebugLanchInfo {
    param (
        $FolderPath = $pwd,
        $LanchJspnPath= "$($psEditor.Workspace.Path)/.vscode/launch.json"
    )

    $proj = Get-Item $FolderPath/*.Tests/bin/Debug/netcoreapp3.1/*.Tests.dll
    $info = Get-Content $LanchJspnPath | ConvertFrom-Json

    $newSetting = [pscustomobject]@{
        name        = "AtCoderFs"
        type        = "coreclr"
        request     = "launch"
        program     = $proj.FullName
        args        = @()
        cwd         = '${workspaceFolder}'
        console     = "internalConsole"
        stopAtEntry = $false
    }
    $newConfigs = $info.configurations.Where{ $_.name -notmatch "AtCoderFs" }
    $newConfigs.Add($newSetting)
    $info.configurations = $newConfigs

    $info | ConvertTo-Json -Depth 5 | Set-Content $LanchJspnPath -Force
}


function Submit-AtCoderTask {
    param (
        $FolderPath = $pwd
    )
    Set-Location $FolderPath
    acc submit -s -- -l 4022
    Set-Location -
}

function Update-FsTemplate {
    $fsTemplatePath = "$(acc config-dir)/fs"
    if (Test-Path $fsTemplatePath) {
        Remove-Item $fsTemplatePath -Recurse -Confirm:$false -Force
    }
    mkdir $fsTemplatePath
    Copy-Item $PSScriptRoot/../template.json $fsTemplatePath -Force
    acc config default-task-choice all
    acc config default-test-dirname-format test
    acc config default-template fs
}

