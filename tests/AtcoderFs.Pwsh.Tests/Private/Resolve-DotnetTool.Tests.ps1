BeforeAll {
    . $PSCommandPath.Replace('tests', 'src').Replace('.Tests', '')

}

Describe "Get-DotnetToolClosure <PackageID>" -ForEach @(@{PackageID = 'paket' }) {
    Context "No Installed" {
        It "Failed" {
            Resolve-DotnetTool $PackageID -ErrorVariable errors -ErrorAction SilentlyContinue
            $errors.Count | Should -Be 1
            $errors[0].Exception | Should -BeOfType System.Management.Automation.CommandNotFoundException
        }
    }

    Context "Installed in Local" {
        BeforeAll {
            dotnet new tool-manifest
            dotnet tool install $PackageID
        }
        It "Init Function" {

            Resolve-DotnetTool $PackageID  | Should -BeNullOrEmpty

            (Get-Command $PackageID).CommandType | Should -Be 'Function'
        }
        AfterAll {
            dotnet tool uninstall $PackageID
        }
    }

    Context "Installed in Global" {
        BeforeAll{
            dotnet tool install --global $PackageID
        }
        It "Return Nothing" {        
            Resolve-DotnetTool $PackageID | Should -BeNullOrEmpty
        }
        AfterAll {
            dotnet tool uninstall --global $PackageID
        }
    }
}