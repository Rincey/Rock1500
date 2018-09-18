$MyVotes = @(
    "Metallica - Fade to Black",
    "Pantera - Walk",
    "Slayer - Raining Blood",
    "Black Sabbath - N.I.B.",
    "Led Zeppelin - Immigrant Song",
    "Devilskin - Little Pills",
    "Shihad - You Again",
    "Disturbed - Voices",
    "Korn - Twisted Transistor",
    "Slipknot - The Negative One",
    "Megadeth - Peace Sells But WHo's Buying",
    "Johnny Cash - Hurt",
    "In This Moment - Oh Lord",
    "Five Finger Death Punch - Jekyll and Hyde",
    "Lynyrd Skynyrd - Free Bird"
)
$lastYear = Import-Csv ".\Full 2017.csv"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)
$count =0 
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
"Tracks gone: $count"
