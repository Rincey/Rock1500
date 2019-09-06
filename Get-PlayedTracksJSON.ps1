Function Get-TotalWeekDays {
    [cmdletbinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "What is the start date?")]
        [ValidateNotNullorEmpty()]
        [DateTime]$Start,
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "What is the end date?")]
        [ValidateNotNullorEmpty()]
        [DateTime]$End
    )
  
    $i = 0
    for ($d = $Start; $d -le $end; $d = $d.AddDays(1)) {
        if ($d.DayOfWeek -notmatch "Sunday|Saturday") {
            $i++    
        }
    } 
    return    $i
} 

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
        
$countdownday = Get-TotalWeekDays -Start "2019-08-25" -End $($track.timestamp.split(" ")[0])
            "`"$($song.artist) - $($song.title)`"
Played at $($track.timestamp.split(" ")[1]) on $($track.timestamp.split(" ")[0]) (Day $countdownday)
Number $($track.rank)
-----------"
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