param (
    [switch]$day,
    [switch]$cumulative,
    [switch]$total
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$rawcountdown = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | 
    convertfrom-json)

if ($total) {
    
    $countdown = $rawcountdown 
    
    $topTen = $countdown |
    Group-Object artist |
    sort-object count -Descending
    
    $topten | Where-Object { $_.count -ge $topten[9].count } | Select-Object Name, Count | Out-GridView -Title "Top Ten Overall"
}

if ($day) {
    
    $newcountdown = $rawcountdown | Select-Object *, @{n = 'date'; e = { $_.timestamp.split(" ")[0] } } | Sort-Object date | Group-Object date
    foreach ($countdown in $newcountdown) {

        $topTen = $countdown.group |
        Group-Object artist |
        sort-object count -Descending

        $topten | Where-Object { $_.count -ge $topten[9].count } | Select-Object Name, Count | Out-GridView -Title "Top Ten $($countdown.name)"
    }
}

if ($cumulative) {
    
    $newcountdown = $rawcountdown | Select-Object *, @{n = 'date'; e = { $_.timestamp.split(" ")[0] } } | Sort-Object date | Group-Object date
    $topten = @()
    foreach ($countdown in $newcountdown) {

        $topTen = $topten + $countdown.group |
        Group-Object artist |
        sort-object count -Descending

        $topten | 
        Where-Object { $_.count -ge $topten[9].count } | 
        Select-Object @{n = 'Date'; e = { $countdown.name } }, Name, Count | 
        Out-GridView -Title "Top Ten Up To $($countdown.name)"
    }
}

