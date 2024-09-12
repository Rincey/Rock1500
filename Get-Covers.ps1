[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$countdown = (Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content |  ConvertFrom-Json  
$covers = $countdown | Group-Object title | Where-Object Count -gt 1

foreach ($cover in $covers) {
    $output = "$($cover.name): "
    foreach ($item in $cover.group) {
        $output += "$($item.artist) ($($item.rank)), "
    }
    $output = $output.Substring(0,$output.Length-2)
    $output
}

