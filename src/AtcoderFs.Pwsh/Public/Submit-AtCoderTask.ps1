function Submit-AtCoderTask {
    param (
        $FolderPath = $pwd
    )
    Set-Location $FolderPath
    acc submit -s -- -l 4022
    Set-Location -
}
