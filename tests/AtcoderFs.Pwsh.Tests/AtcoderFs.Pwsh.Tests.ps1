BeforeAll{
    dotnet tool install paket

    $PSCommandPath -creplace 'tests', 'src' -creplace '.Tests'
    | Split-Path -Parent
    | Import-Module -Force
}
Describe "Init inner function test" {
    It "Check function paket work" {
        InModuleScope AtcoderFs.Pwsh {
            $expected = dotnet paket --version
            paket --version | Should -Be $expected
        }
    }
}

AfterAll {
    dotnet tool uninstall paket
}