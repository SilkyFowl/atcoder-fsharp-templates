function Update-AtCoderDebugLanchInfo {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        $FolderPath = $pwd,
        $LanchJspnPath = "$($psEditor.Workspace.Path)/.vscode/launch.json"
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
