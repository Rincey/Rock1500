[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$rawcountdown = (Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | 
ConvertFrom-Json  
$countdown = $rawcountdown | Select-Object @{L = 'Combined'; E = { "$($_.artist) - $($_.title)" } }


if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}
$rawrock2019 = Import-Csv "$reportfolder\full 2019.csv" 
$rock2019 = $rawrock2019 | Select-Object @{L = 'Combined'; E = { "$($_.artist) - $($_.title)" } }


"Already played:"
(Compare-Object -ReferenceObject $rock2019.combined -DifferenceObject $countdown.combined -IncludeEqual | ? sideindicator -eq "==").count

"
Didn't play last year:"
(Compare-Object -ReferenceObject $rock2019.combined -DifferenceObject $countdown.combined -IncludeEqual | ? sideindicator -eq "=>").count

"
Yet to play:"
$rock2019.combined | foreach-object {
    if ($countdown.combined -notcontains $_) { 
        "$_" 
    }
}