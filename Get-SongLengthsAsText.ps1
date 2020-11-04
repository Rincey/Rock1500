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

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}


$filename = "$reportfolder\songlengths.csv"
$AlreadyPlayed = Import-Csv $filename


$data = $AlreadyPlayed | Where-Object day -eq 1 | Sort-Object -Descending rank
$totalDayLength = ((get-date $data[-1].start)  - (get-date $data[0].start )).totalmilliseconds + $data[-1].length
$noLength = ($data | Where-Object length -eq 0).count

$songLength = 0
    foreach ($item in $data) {

    }


