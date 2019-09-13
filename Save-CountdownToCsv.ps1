[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$year = get-date -Format yyyy
$Rock1500 = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)
$Rock1500.GetEnumerator() | Export-Csv ".\Full $year.csv" -NoTypeInformation