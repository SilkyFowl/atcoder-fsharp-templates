function Get-AtCoderContestInfo {
    Get-Content contest.acc.json | ConvertFrom-Json
}
