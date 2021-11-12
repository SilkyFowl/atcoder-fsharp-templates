using namespace System.Management.Automation.Language

. $PSScriptRoot\FsCodeTemplates.ps1

$exportFunctions = @()

Get-ChildItem $PSScriptRoot\Private\*.ps1
| ForEach-Object {
    . $_.FullName
}
Get-ChildItem $PSScriptRoot\Public\*.ps1
| ForEach-Object {
    . $_.FullName
    $exportFunctions += [scriptblock]::Create((Get-Content $_.FullName -Raw)).Ast.FindAll({ $args[0] -is [FunctionDefinitionAst] }, $false).Name
}

# check require tools
try {
    Get-Command acc, oj -ErrorAction Stop
} catch {
    throw 'require tools: acc,oj'
}

# Setup dotnet tools
@('paket')
| ForEach-Object {
    Resolve-DotnetTool $_
}

Export-ModuleMember -Function $exportFunctions