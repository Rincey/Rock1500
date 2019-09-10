[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)


$hash = @{}

foreach ($track in $AlreadyPlayed) {
    $year = $track.albumyear
    if ($hash.ContainsKey($year)) {
            $hash.$year += 1
        } else {
            $hash.$year = 1
        }
}
$hash.GetEnumerator() | sort name