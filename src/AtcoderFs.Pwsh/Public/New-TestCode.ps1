function New-TestCode {
    [CmdletBinding(SupportsShouldProcess)]
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
