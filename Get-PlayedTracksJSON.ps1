$MyVotes = get-content .\picks2019.json | ConvertFrom-Json
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)
$count = 0 
$Sets = ($myvotes.picks | Get-Member | Where-Object { $_.membertype -eq 'NoteProperty' }).Name
foreach ($VoteSet in $Sets) {
    "
Vote Set '$($VoteSet)':"
    foreach ($track in $AlreadyPlayed) {
        $song = "" | Select-Object artist, title
        $song.artist = $track.artist
        $song.title = $track.title

        if ($MyVotes.picks.$VoteSet -match $song) {
        

            "`"$($song.artist) - $($song.title)`"
Played at $($track.timestamp.split(" ")[1]) on $($track.timestamp.split(" ")[0])
Number $($track.rank)
        "
            $count += 1
        }

    }
    if ($count -eq 0) {
        "None gone in '$($voteset)'"
    }
    else {
        "Tracks gone in Set '$($voteset)': $count"
    }
    $count = 0
    "---------------------------------"
}