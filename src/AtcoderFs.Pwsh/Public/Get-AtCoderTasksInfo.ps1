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
