param (
    [switch]$day,
    [switch]$cumulative,
    [switch]$total,
    [switch]$today
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$rawcountdown = (Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | 
ConvertFrom-Json

$countdown = $rawcountdown | Select-Object *,@{n='Change';e={$_.rankOneYearAgo - $_.rank}}

"
Biggest Gains"
$countdown | Sort-Object change -Descending | Select-Object -First 10 rank,title,artist,change

"
Biggest Losers"
$countdown | Sort-Object change  | Select-Object -First 10 rank,title,artist,change

"
No Change"
$countdown | Where-Object{$_.change -eq 0} | Select-Object rank,title,artist