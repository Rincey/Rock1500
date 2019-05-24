#Requires -modules PSSpotify

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#$Rock1500_2018 = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)
$Rock1500_2018 = (Get-Content '.\KingOfCountdowns (2019).csv' | ConvertFrom-Csv)

Connect-Spotify -ClientIdSecret (Import-Clixml ..\spotify.credential2) -KeepCredential -Debug -RedirectUri http://localhost:8001

$playlist = Get-SpotifyPlaylist -Name "King of Countdowns (2019)" -My

foreach ($track in $Rock1500_2018) {
    $spotifyTracks = Find-SpotifyTrack -filter "$($track.title) $($track.artist)" -Limit 10
    $options = @()
    $index = 0
    $choice = -1
    "$($track.rank): $($track.title) - $($track.artist)"
    foreach ($spotifytrack in $spotifyTracks) {
        $options += $spotifytrack
        $duration = New-TimeSpan -Seconds ($spotifytrack.DurationMs / 1000)
        "`t[$index] $($spotifytrack.name) - $($spotifytrack.artists -join ",") - $($spotifytrack.album) ($($duration.minutes)m$($duration.Seconds)s)"
        $index += 1
    }
    Do {
        $choice = Read-Host "Select track to add to playlist" 
    } while (!($choice -in 0..($spotifyTracks.length-1)))
    
    $spotifyTracks[$choice]
    #Add-SpotifyTracktoPlaylist -Id $playlist.Id -Tracks $spotifyTracks[$choice].uri
}
