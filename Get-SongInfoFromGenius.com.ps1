(New-Object System.Net.WebClient).Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($PSScriptRoot) {
    $scriptfolder = $PSScriptRoot
}
else {
    $scriptfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}

$creds = get-content "$scriptfolder\..\genius.json" | ConvertFrom-Json

$uathURL = "https://api.genius.com/oauth/authorize"

$client_id = $creds.client_id
$redirect_uri = "https://localhost"
$scope = ""
state: A value that will be returned with the code redirect for maintaining arbitrary state through the authorization process
response_type: Always "code"