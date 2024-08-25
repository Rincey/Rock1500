$rwc = Import-Csv '.\RWC2023 EST.csv'
$rwcNZ = @()

foreach($item in $rwc) {
$row = "" | select NZT,Match,Group
$row.NZT = (get-date ((get-date $item.Date -format "yyyy/MM/dd") + " " +$item.Time)).AddHours(10)
$row.match = $item.Match
$row.group = $item.Group

$rwcNZ += $row
}

$rwcnz | Export-Csv -NoTypeInformation ".\rwc2023 NZT.csv"

