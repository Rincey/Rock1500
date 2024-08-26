#Requires -modules PSSpotify

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#$Rock1500_2018 = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/sound -UseBasicParsing).content | convertfrom-json)
#$Rock1500_2018 = (Get-Content '.\Full 2018.csv' | ConvertFrom-Csv)

#$Rock1500_2018 = (Get-Content ".\songs for richard.csv" | ConvertFrom-Csv)
$Rock1500_2018 = (Get-Content ".\spotify\moonsongs.csv" | ConvertFrom-Csv)


Connect-Spotify -ClientIdSecret (Import-Clixml "E:\Git Repositories\spotify.credential2") -KeepCredential -Debug -RedirectUri http://localhost:8001

Connect-Spotify  -KeepCredential -Debug -RedirectUri http://localhost:8001


$playlist = Get-SpotifyPlaylist -Name "Moon Songs" -My

foreach ($track in $Rock1500_2018) {
    $spotifyTrack = Find-SpotifyTrack -filter "$($track.title) $($track.artist)" -Limit 1
    "CSV: [ $($track.artist); $($track.title)]. Spotify: [$($spotifyTrack.count); $($spotifyTrack.Artists -join("/")); $($spotifyTrack.Name)]"
    if ($spotifyTrack.count -eq 1) {
         Add-SpotifyTracktoPlaylist -Id $playlist.Id -Tracks $spotifyTrack.uri
    }
    
}


