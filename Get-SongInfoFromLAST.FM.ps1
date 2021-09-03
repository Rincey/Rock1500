(New-Object System.Net.WebClient).Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($PSScriptRoot) {
    $scriptfolder = $PSScriptRoot
}
else {
    $scriptfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}

$creds = get-content "$scriptfolder\..\lastfm.json" | ConvertFrom-Json

$authURL = "http://ws.audioscrobbler.com/2.0/?method=auth.gettoken&api_key=$($creds.API_Key)&format=json"
$token = Invoke-RestMethod -Method Get  -Uri $authURL
$authorisation = "http://www.last.fm/api/auth/?api_key=$($creds.API_Key)&token=$($token.token)"
$authorisation
