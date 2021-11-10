function Update-FsTemplate {
    [CmdletBinding(SupportsShouldProcess)]
    param (
    )
    dotnet new --install AtcoderFs.Templates
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
