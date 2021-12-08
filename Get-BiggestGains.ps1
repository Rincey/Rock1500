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

$countdown | Sort-Object change -Descending | Select-Object -First 20 rank,title,artist,change | Out-GridView -Title "Biggest Gains"
$countdown | Sort-Object change  | Select-Object -First 20 rank,title,artist,change | Out-GridView -Title "Biggest Losers"
$countdown | Where-Object{$_.change -eq 0} | Select-Object rank,title,artist | Out-GridView -Title "No Change"