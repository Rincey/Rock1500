param (
    [switch]$day
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$rawcountdown = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | 
    convertfrom-json)


if ($day) {
    
    $newcountdown = $rawcountdown | select *,@{n='date';e={$_.timestamp.split(" ")[0]}}
    $newcountdown | Group-Object date
    

    $topTen = $countdown |
    Group-Object artist |
    sort-object count -Descending

    $topten | Where-Object { $_.count -ge $topten[9].count } | Select-Object Name, Count | Out-GridView -Title "Top Ten"
}

