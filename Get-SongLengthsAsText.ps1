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

Function Get-HumanReadableTime {
    param (
        $ms
    )
    $tmpTimeSpan = New-TimeSpan -Seconds ([int32]($ms / 1000))

    return "$($tmpTimeSpan.hours)h $($tmpTimeSpan.minutes)m $($tmpTimeSpan.seconds)s"
}



[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}


$filename = "$reportfolder\songlengths.csv"
$AlreadyPlayed = Import-Csv $filename
$AlreadyPlayed = $AlreadyPlayed | 
Select-Object @{L = 'newrank'; E = { ($_.rank).padleft(4, "0") } },
day,
Length,
start

$days = $AlreadyPlayed.day | Select-Object  -Unique 
$days = ($days | ForEach-Object { [int32]$_ }) | Sort-Object

$valueForMoneyreport = @()

foreach ($day in $days) {
    $data = $AlreadyPlayed | Where-Object day -eq $day | Sort-Object -Descending newrank
    $totalDayLength = ((get-date $data[-1].start) - (get-date $data[0].start )).totalmilliseconds + $data[-1].length
    $noLength = ($data | Where-Object length -eq 0).count

    $songLength = 0
    foreach ($item in $data) {
        $songLength += $item.length
    }

    $percentSongs = [int](100 * $songLength / $totalDayLength)
    $percentNoSongs = 100 - $percentSongs

    $averageSongLength = $songLength / ($data.count)
    $missingTime = $noLength * $averageSongLength
    $adjustedSongLength = $songLength + $missingTime
    $adjustedPercentSongs = [int](100 * $adjustedSongLength / $totalDayLength)
    $adjustedPercentNoSongs = 100 - $adjustedPercentSongs

    $row = "" | 
    Select-Object `
        day,
    songs,
    noLength,
    totalDay,
    totalMusic,
    percentMusic,
    totalNoMusic,
    percentNoMusic,
    adjustedTotalMusic,
    adjustedPercentMusic,
    adjustedTotalNoMusic,
    adjustedPercentNoMusic


    $row.Day = $day
    $row.Songs = $($data.count)
    $row.nolength = $noLength
    $row.totalday = $(Get-HumanReadableTime $totalDayLength)
    $row.totalmusic = $(Get-HumanReadableTime $songLength) 
    $row.percentmusic = $percentSongs
    $row.totalnomusic = $(Get-HumanReadableTime $($totalDayLength - $songLength)) 
    $row.percentnomusic = $percentNoSongs
    $row.adjustedTotalMusic = $(Get-HumanReadableTime $adjustedSongLength) 
    $row.adjustedPercentMusic = $adjustedPercentSongs
    $row.adjustedTotalNoMusic = $(Get-HumanReadableTime $($totalDayLength - $adjustedsongLength)) 
    $row.adjustedPercentNoMusic = $adjustedpercentNoSongs

$valueForMoneyreport += $row
}

$valueForMoneyreport | Out-GridView

