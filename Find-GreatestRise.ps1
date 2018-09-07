[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$jump = 1303
$possibles = @()
$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)
$lastYear = Import-Csv ".\Full 2017.csv"
$candidates = $lastYear | Where-Object {[int]($_.rank) -gt $jump}

# Remove already played
foreach ($track in $candidates) {
    $flag = $false
    foreach ($apTrack in $AlreadyPlayed) {
        if (($apTrack.artist -eq $track.artist) -and ($apTrack.title -eq $track.title)) {
            $flag = $true
        }
    }
    if (!($flag)) {
        $possibles += $track
    }
}

$soonest = [int]$possibles[-1].rank - $jump
if ($soonest -lt [int]$AlreadyPlayed[0].rank) {
    #eliminate more
}
$possibles |Format-Table -AutoSize rank,artist, title
"Candidates remaining: $($possibles.count)"

"Soonest possible candiate is #$soonest`: `"$($possibles[-1].artist) - $($possibles[-1].title)`""
"Countdown currently at #$($AlreadyPlayed[0].rank)"
