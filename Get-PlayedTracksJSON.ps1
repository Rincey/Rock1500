$MyVotes = get-content .\picks2019.json | ConvertFrom-Json
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)
$count =0 
$Sets = $myvotes.picks | gm | ?{$_.}
foreach ($VoteSet in $myvotes.picks) {

foreach ($track in $AlreadyPlayed) {
    $song = "$($track.artist) - $($track.title)"
    if ($MyVotes -match $song) {
        $oldrank = "didn't place"
        foreach ($oldtrack in $lastYear) {
            if (($oldTrack.artist -eq $track.artist) -and ($oldTrack.title -eq $track.title)) {
                $oldrank = "was number $($oldtrack.rank)"
                
            }
        }

        "`"$song`"
        Played at $($track.timestamp)
        Number $($track.rank)
        Last year it $oldrank
        "
        $count += 1
    }

}
"Tracks gone in Set $($MyVotes.picks): $count"
}