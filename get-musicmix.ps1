
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}
$filename = "$reportfolder\..\musicmixapikey.txt"
$key = Get-Content $filename


$queryTerms = "q_artist=metallica
q_track=master of puppets
f_track_release_group_first_release_date_min=19890101
f_track_release_group_first_release_date_maz=19891231" -replace "
","&"


$url = "http://api.musixmatch.com/ws/1.1/track.search?apikey=$key&$queryterms"
$response = invoke-restmethod -Uri $url -Method Get

$response.message.body.track_list.track | select track_name

