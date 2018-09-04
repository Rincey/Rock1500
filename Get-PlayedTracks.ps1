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

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)

foreach ($track in $AlreadyPlayed) {
    $song = "$($track.artist) - $($track.title)"
    if ($MyVotes -match $song) {
        "$song played. Number $($track.rank). At $($track.timestamp)"
    }

}
