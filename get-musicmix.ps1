
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}
$filename = "$reportfolder\..\musicmixapikey.txt"
$key = Get-Content $filename

$artist = "black label society"
$track = "fire it up"
$albumYear = "2005"

$queryTerms = "q_artist=$artist
q_track=$track
f_track_release_group_first_release_date_min=$($albumYear)0101
f_track_release_group_first_release_date_max=$($albumYear)1231" -replace "
","&"

$apiEntryPoint = "track.search"

$url = "http://api.musixmatch.com/ws/1.1/$apiEntryPoint`?apikey=$key&$queryterms"
$response = invoke-restmethod -Uri $url -Method Get

$response.message.body.track_list.track | select track_name


$queryTerms ="commontrack_id=74970556"
$apiEntryPoint = "track.get"

$url = "http://api.musixmatch.com/ws/1.1/$apiEntryPoint`?apikey=$key&$queryterms"
$response = invoke-restmethod -Uri $url -Method Get
