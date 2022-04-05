$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/sound -UseBasicParsing).content | convertfrom-json)

if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}
$AlreadyPlayed | Export-Csv "$reportfolder\SoundHallofFame2020.csv" -NoTypeInformation

$AlreadyPlayed = $AlreadyPlayed | select-Object *,@{L='RankNumber';E={[int]($_.rank)}}

$AlreadyPlayed | 
sort-object -Descending ranknumber | 
select-Object @{L="Song";E={"#$($_.rank) $($_.artist) - $($_.title)"}}