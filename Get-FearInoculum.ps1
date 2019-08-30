$trackIDs = @{
    "Fear Inoculum"  = "q7DfQMPmJRI"
    "Pneuma"         = "FRURmhFE6BI"
    "Invincible"     = "CtiuMnhP3Qk"
    "Descending"     = "crI1ApHQXO0"
    "Culling Voices" = "vBlGzGh8k48"
    "7empest"        = "wVjcmOKTqJc"
}

$downloadfolder = "C:\temp\Tool"

foreach ($track in $trackids.keys) {

$filename = "Tool - Fear Inoculum - $track"
$YTurl = $trackIDs.$track

$command = "youtube-dl -o `"$downloadfolder\$filename.mp4`" -f best `"$YTurl`" -x -k --audio-format mp3"
#$command

Invoke-Expression -Command $command

Move-Item "$downloadfolder\$filename.mp3" "$downloadfolder\extracted_audio"

}

