
$downloadrootfolder = "E:\Downloads\Charlie Music"
$inputfile = "$downloadrootfolder\charlie music input file.csv"
$downloadfolder = "$downloadrootfolder\downloads"

<# 

*** MP3 Tagging ***
Uses PS module ID3
install-module id3 from an elevated PS prompt
. get-id3tag
. set-id3tag

set-id3tag -path <object? guessing from the file object?> -tags <IDictionary>

*** Audio Extraction ***
Uses ffmpeg - google it. Binaries exist. Extract into download folder
ACTUALLY: Get the one from the yt-dlp folk

*** YT Downloader ***
yt-dlp.exe - google yt-dlp windows to find their release pages

#>


$songs = Import-Csv $inputfile  -Delimiter ","

foreach ($line in $songs) {
    "Searching for `"$($line.Artist) $($line.Song)`""
    $searchcommand = @"
yt-dlp.exe ytsearch:"$($line.Artist) $($line.Song)" --get-id --get-title
"@
    $result = Invoke-Expression $searchcommand
    "`tFound $($result[0]). (id: $($result[1]))"
    
    $filename = "$downloadfolder\$($line.Artist) - $($line.Song)"
    $downloadcommand = @"
yt-dlp.exe -o "$filename" -f 'ba' $($result[1]) -x --audio-format mp3
"@
    Invoke-Expression -Command $downloadcommand

    $mp3 = get-item "$filename.mp3"
    $hashtable = @{
        title = $line.Song
        artists = $line.Artist
    }
Set-Id3Tag -Path $mp3 -Tags $hashtable


}