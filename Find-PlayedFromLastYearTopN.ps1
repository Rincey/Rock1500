[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$N = 100
$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)
$lastYear = Import-Csv ".\Full 2017.csv"

$candidates = $lastyear[0..($N - 1)] 
$count = 0
"Top $N from last year already played

(last year) this year: Artist - Title"

foreach ($track in $candidates) {
    foreach ($apTrack in $AlreadyPlayed) {
        if (($apTrack.artist -eq $track.artist) -and ($apTrack.title -eq $track.title)) {
            "($($Track.rank)) $($apTrack.rank): $($apTrack.artist) - $($apTrack.title)"
            $count += 1
        }
    }

}
"Total: $count"