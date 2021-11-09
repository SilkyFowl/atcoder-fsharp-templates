using namespace System.Management.Automation.Language

# check require tools
try {
    Get-Command acc,oj -ErrorAction Stop
}
catch {
    throw 'require tools: acc,oj'
}

. $PSScriptRoot\FsCodeTemplates.ps1

$exportFunctions = @()

Get-ChildItem $PSScriptRoot\Public\*.ps1
| ForEach-Object {
    . $_.FullName
    $exportFunctions += [scriptblock]::Create((Get-Content $_.FullName -Raw)).Ast.FindAll({$args[0] -is [FunctionDefinitionAst]},$false).Name
}

Export-ModuleMember -Function $exportFunctions