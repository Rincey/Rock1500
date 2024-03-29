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

if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}

$MyVotes = get-content $reportfolder\picks2023.json | ConvertFrom-Json 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)
$count = 0 
$Sets = ($myvotes.picks | Get-Member | Where-Object { $_.membertype -eq 'NoteProperty' }).Name
foreach ($VoteSet in $Sets) {
    $VoteSetPlayed = @()
    
    "
Vote Set '$($VoteSet)':"
    foreach ($track in $AlreadyPlayed) {
        $song = "" | Select-Object artist, title
        $song.artist = $track.artist
        $song.title = $track.title

        if ($MyVotes.picks.$VoteSet -like $song) {
$VoteSetPlayed += $song
$countdownday = Get-TotalWeekDays -Start $($AlreadyPlayed[-1].timestamp.split(" ")[0]) -End $($track.timestamp.split(" ")[0])
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
    "Remaining:"
    $AdjustedVoteSet = $MyVotes.picks.$VoteSet | Select-Object *,@{n='ArtistTitle';e={"$($_.Artist) - $($_.title)"}}
    $AdjustedVoteSetPlayed = $VoteSetPlayed | Select-Object *,@{n='ArtistTitle';e={"$($_.Artist) - $($_.title)"}}
    Compare-Object -ReferenceObject $AdjustedVoteSet.ArtistTitle -DifferenceObject $AdjustedVoteSetPlayed.ArtistTitle -PassThru
    $count = 0
    "================================"
}

