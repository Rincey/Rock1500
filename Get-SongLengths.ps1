#Requires -modules PSSpotify
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}
$outputFilename = "$reportfolder\songlengths.csv"
$credsFilename = "$(split-path $reportfolder)\spotify.credential2"




Connect-Spotify -ClientIdSecret (Import-Clixml $credsFilename) -KeepCredential -Debug -RedirectUri http://localhost:8001


#$spotifyTrack = Find-SpotifyTrack -filter "$($track.title) $($track.artist) $($track.album)" -Limit 1
$spotifyTrack = Find-SpotifyTrack -filter "glory glory head like a hole" -Limit 1

<#

Name                                     Artists                                  Album                                    Explict                   DurationMs
----                                     -------                                  -----                                    -------                   ----------
Glory Glory                              {Head Like A Hole}                       Blood Will Out                           False                     211423

#>

