[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference ="SilentlyContinue"
$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)
$HighestDebut = ($AlreadyPlayed | Where-Object rankOneYearAgo -eq "DEBUT")[0]
$HighestRise = $AlreadyPlayed | 
where-object {$_.rankOneYearAgo -ne "debut" -and $_.rankOneYearAgo -ne "RE-ENTRY"}| 
Select-Object @{L='Rise';E={[int]($_.rankoneyearago) - [int]($_.rank)}},* | 
Sort-Object -Descending rise 

"
Highest Debut:"
$HighestDebut | Select-Object title,artist,rank | Format-List

"
Highest Rise:"
$HighestRise[0] | Select-Object title,artist,Rise,rank,rankOneYearAgo | Format-List
