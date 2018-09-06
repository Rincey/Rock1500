$jump = 1303
$lastYear = Import-Csv ".\Full 2017.csv"
$candidatesTemp = $lastYear | Where-Object {[int]($_.rank) -ge $jump}

$candidates = @()
foreach ($item in $candidatesTemp) {
    $row = "" | Select-Object title, artist
    #$row.rank = $item.rank
    $row.title = $item.title
    $row.artist = $item.artist
    $candidates += $row
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$AlreadyPlayedTemp = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)
$AlreadyPlayed = @()
foreach ($item in $AlreadyPlayedTemp) {
    $row = "" | Select-Object title, artist
    #$row.rank = $item.rank
    $row.title = $item.title
    $row.artist = $item.artist
    $AlreadyPlayed += $row
}

$possibles = @()
foreach ($track in $candidates) {
    if ($AlreadyPlayed -contains $track) {
        $possibles += $track
    }
}

$possibles |Format-Table -AutoSize artist,title
