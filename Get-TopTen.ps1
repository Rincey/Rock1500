[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$countdown = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | 
    convertfrom-json)

    $topTen = $countdown |
    Group-Object artist |
    sort-object count -Descending

$topten| Where-Object {$_.count -ge $topten[9].count} | Format-Table Name,Count
$countdown[0..10] | Format-Table -a rank,artist,title
