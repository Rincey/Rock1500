
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)


$alreadyplayed | Where-Object{
    ($_.artist -eq "limp bizkit") `
    -or ($_.artist -eq "blindspott") `
    -or (($_.artist -eq "nirvana") -and ($_.title -eq "stay away")) `
    -or (($_.artist -eq "pantera") -and ($_.title -eq "slaughtered")) `
    -or (($_.artist -eq "rage against the machine") -and ($_.title -eq "bullet in the head"))
} | Select-Object rank,title,artist

