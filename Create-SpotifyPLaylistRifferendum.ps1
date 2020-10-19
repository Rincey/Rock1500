#Requires -modules PSSpotify

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#$Rock1500_2018 = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)


if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}


$Rock1500_2018 = (Get-Content "$reportfolder\Rifferendum2020.csv" | ConvertFrom-Csv)

Connect-Spotify -ClientIdSecret (Import-Clixml ..\spotify.credential2) -KeepCredential -Debug -RedirectUri http://localhost:8001

$playlist = Get-SpotifyPlaylist -Name "Rifferendum 2020" -My

foreach ($track in $Rock1500_2018) {
    $spotifyTrack = Find-SpotifyTrack -filter "$($track.title) $($track.artist) $($track.album)" -Limit 1
    "$($track.rank) $($track.title) $($track.artist) $($spotifyTrack.count)"
    if ($spotifyTrack.count -eq 1) {
         Add-SpotifyTracktoPlaylist -Id $playlist.Id -Tracks $spotifyTrack.uri
    }
    
}

