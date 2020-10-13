[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference ="SilentlyContinue"
$N = 2000
$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)


$count = 0
"Top $N from last year already played

(last year) this year: Artist - Title"
foreach ($track in $AlreadyPlayed){
    if ([int]$track.rankOneYearAgo -le $N){
        "($($Track.rankOneYearAgo)) $($Track.rank): $($Track.artist) - $($Track.title)"
        $count += 1  
    }
}
"Total: $count"

$ErrorActionPreference = "Continue"