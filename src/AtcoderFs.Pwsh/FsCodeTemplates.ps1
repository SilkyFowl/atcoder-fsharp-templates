
$Script:TemplateTestType = @'
let task$($_.Label) =
    { Title = "$($_.Title)"
      FolderName = "$($_.Label.ToLower())"
      Memory = $($_.Memory[0])
      Timeout = sec $("{0:0.0}" -f [timespan]::new(0,0,$_.Timeout[0]).TotalSeconds) }

'@

$Script:TemplateTestFunction = @'
    // sampleFileTests task$($_.Label) Program.$($_.Label.ToLower())
'@

$Script:TemplateTestListHeader = @'

// Info: https://atcoder.jp/contests/$($info.contestId)/tasks_print

[<Tests>]
let testAcc =
    [ 
'@

$Script:TemplateTestListFooter = @'
    ]
    |> List.concat
    |> testList "Sample File Tests"
'@
