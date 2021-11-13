using namespace System.Management.Automation.Language
using namespace System.Collections.Generic

. $PSScriptRoot\FsCodeTemplates.ps1

$exportFunctions = [List[string]]::new()

Get-ChildItem $PSScriptRoot\Private\*.ps1
| ForEach-Object {
    . $_.FullName
}
Get-ChildItem $PSScriptRoot\Public\*.ps1
| ForEach-Object {
    . $_.FullName
    [Parser]::ParseFile(
        $_.FullName, [ref]$null, [ref]$null
    ).FindAll(
        { $args[0] -is [FunctionDefinitionAst] }, $false
    ).ForEach{
        $exportFunctions.Add($_.Name)
    }
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