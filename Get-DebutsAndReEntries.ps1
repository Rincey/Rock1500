param (
    [switch]$latestOnly
)


(New-Object System.Net.WebClient).Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}

$allcountdowns = New-Object 'System.Collections.Generic.List[object]'

if (!($latestOnly)) {
    $oldcsvs = get-childitem -Path $reportfolder -Filter "Full ????.csv"
    foreach ($csv in $oldcsvs) {
        $file = Import-Csv $csv.fullname
        $countdownyear = $csv.name[5..8] -join ""
        $countdownyear
        $file | ForEach-Object {
            $_ | Add-Member -MemberType NoteProperty -Name 'Year' -Value $countdownyear
            if ($_.rankOneYearAgo -is [int]) {
                $_ | Add-Member -MemberType NoteProperty -Name deltaRank -Value ([int]$_.rankOneYearAgo - [int]$_.rank)
            }
        }
    
        $allcountdowns.add($file)
    }
}


(get-date).Year
$thisyear = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)
$thisyear | ForEach-Object {
    $_ | Add-Member -MemberType NoteProperty -Name 'Year' -Value (get-date).Year
    if ($_.rankOneYearAgo -is [int]) {
        $_ | Add-Member -MemberType NoteProperty -Name deltaRank -Value ([int]$_.rankOneYearAgo - [int]$_.rank)
    }
}
$allcountdowns.add($thisyear)
$allcountdowns = ($allcountdowns | ForEach-Object { $_ })

$years = $allcountdowns | select-Object -unique -ExpandProperty Year

foreach ($year in $years) {
    $numDebuts = $allcountdowns | Where-Object { ($_.year -eq $year) -and ($_.rankOneYearAgo -eq "DEBUT") } | Measure-Object | select-Object -ExpandProperty Count
    $highestDebut = $allcountdowns | Where-Object { ($_.year -eq $year) -and ($_.rankOneYearAgo -eq "DEBUT") } | select-Object -first 1
    $numReentries = $allcountdowns | Where-Object { ($_.year -eq $year) -and (($_.rankOneYearAgo -eq "RE-ENTRY") -or ($_.rankOneYearAgo -eq "R/E")) } | Measure-Object | select-Object -ExpandProperty Count
    $highestReentry = $allcountdowns | Where-Object { ($_.year -eq $year) -and (($_.rankOneYearAgo -eq "RE-ENTRY") -or ($_.rankOneYearAgo -eq "R/E")) } | select-Object -first 1
    $highestJump = $allcountdowns | Where-Object { ($_.year -eq $year) } | sort-object -Descending deltaRank | select-Object -first 1
    $highestFall = $allcountdowns | Where-Object { ($_.year -eq $year) } | sort-object -Descending deltaRank | select-Object -Last 1

    "Year: $year"
    "Number of Debuts: $numDebuts"
    "Highest Debut: #$($highestDebut.rank) -  $($highestDebut.title) - $($highestDebut.artist)"
    "Number of Re-entries: $numReentries"
    "Highest Re-entry: #$($highestReentry.rank) -  $($highestReentry.title) - $($highestReentry.artist)"
    "Biggest Jump: #$($highestJump.rank) (from $($highestJump.rankOneYearAgo))  $($highestJump.title) - $($highestJump.artist)"
    "Biggest Fall: #$($highestFall.rank) (from $($highestFall.rankOneYearAgo))  $($highestFall.title) - $($highestFall.artist)"
    if ($year -eq ((get-date).year)) {
        "(So far!!)"
    }
    "
"

}

