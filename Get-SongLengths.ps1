#Requires -modules PSSpotify
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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
$outputFilename = "$reportfolder\songlengths.csv"
$credsFilename = "$(split-path $reportfolder)\spotify.credential2"

if ([System.IO.File]::Exists($outputFilename)) {
    $data = Get-Content $outputFilename | ConvertFrom-Csv
}
else {
    $data = "" | Select-Object rank, day, start, Length

}


Connect-Spotify -ClientIdSecret (Import-Clixml $credsFilename) -KeepCredential -Debug -RedirectUri http://localhost:8001
$report = @()

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)

foreach ($track in $AlreadyPlayed) {

    if ($data.rank -notcontains $track.rank) {
        $spotifyTrack = Find-SpotifyTrack -filter "$($track.title) $($track.artist) $($track.album)" -Limit 1
        
        "$($track.rank) $($track.title) $($track.artist) $($spotifyTrack.count)"
        if ($spotifyTrack.count -eq 1) {
            $length = $spotifyTrack.DurationMs
        }
        else {
            $length = 0
        }
        $row = "" | Select-Object rank, day, start, Length
        $row.rank = $track.rank
        $row.day = Get-TotalWeekDays -Start $($AlreadyPlayed[-1].timestamp.split(" ")[0]) -End $($track.timestamp.split(" ")[0])
        $row.start = $track.timestamp
        $row.length = $length
        $report += $row
    }
}

$report | Export-Csv -Append $outputFilename -NoTypeInformation


