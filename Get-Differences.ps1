[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$countdown = (Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | 
ConvertFrom-Json  
#countdown = $rawcountdown | ForEach-Object { "$($_.artist) - $($_.title)" } 


if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}
$lastyear = Import-Csv "$reportfolder\full 2019.csv" 
#$rock2019 = $rawrock2019 | foreach-Object { "$($_.artist) - $($_.title)" } 

$report = @()
foreach ($lastYearTrack in $lastyear) {
    foreach ($thisyearTrack in $countdown) {
        if (($lastYearTrack.artist -eq $thisyearTrack.artist) -and ($lastYearTrack.title -eq $thisyearTrack.title)) {
            $report += $lastYearTrack
        }

    }
}

#Tracks from last Year that haven't played yet
$zzz = $lastyear |Where-Object{$report -notcontains $_}
$zzz | Select-Object rank,title,artist