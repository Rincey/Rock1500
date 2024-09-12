(New-Object System.Net.WebClient).Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}

$thisyear = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)
$lastyear = Import-Csv "$reportfolder\full $(((get-date).Year)-1).csv"

$thisyearSimple = $thisyear | Select-Object @{L='Entry';E={"$($_.title) ~ $($_.artist)"}}
$lastyearSimple = $lastyear | Select-Object @{L='Entry';E={"$($_.title) ~ $($_.artist)"}}

$lastArray = $lastyearSimple | Select-Object -ExpandProperty Entry
$thisArray = $thisyearSimple | Select-Object -ExpandProperty Entry


$notplayed = $lastArray |Where-Object {$_ -notin $thisArray} 
foreach ($item in $notplayed) {
    $artist = $item.split('~')[1].trim()
    $title = $item.split('~')[0].trim()
    $lastyear | Where-Object {($_.title -eq $title) -and ($_.artist -eq $artist)} | Select-Object rank,title,artist
}

