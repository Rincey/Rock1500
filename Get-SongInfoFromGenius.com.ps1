(New-Object System.Net.WebClient).Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($PSScriptRoot) {
    $scriptfolder = $PSScriptRoot
}
else {
    $scriptfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}

$creds = get-content "$scriptfolder\..\genius.json" | ConvertFrom-Json

