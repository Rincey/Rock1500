[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}
$outputFilename = "$reportfolder\songlengths.csv"
$AlreadyPlayed = import-csv "$reportfolder\full 2020.csv"

$existingSonglengths = import-csv $outputFilename
$missingLengths = $existingSonglengths | where-object length -eq 0
$gotLengths = $existingSonglengths | where-object length -ne 0
foreach ($missing in $missingLengths) {
    
    $title = ($AlreadyPlayed | Where-Object rank -eq $missing.rank).title
    #$title = [System.Web.HttpUtility]::UrlEncode(($AlreadyPlayed | Where-Object rank -eq $missing.rank).title)
    $artist = ($AlreadyPlayed | Where-Object rank -eq $missing.rank).artist
    #$artist = [System.Web.HttpUtility]::UrlEncode(($AlreadyPlayed | Where-Object rank -eq $missing.rank).artist)
    #$search = [System.Web.HttpUtility]::UrlEncode("$title")
    $search = "$title $artist"
    $result = Invoke-RestMethod -Method get -Uri "https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=$search&utf8=&format=json"
    #$pageid = $result.query.search[0..9] | Select-Object pageid, snippet | Out-GridView -PassThru | select-object -ExpandProperty pageid
    $pageid = $result.query.search[0] | select-object -ExpandProperty pageid
    $parse = Invoke-RestMethod -Method Get -Uri "https://en.wikipedia.org/w/api.php?action=parse&pageid=$pageid&prop=wikitext&format=json"
    Write-Output "$artist - $title"

    <#
$parse.parse.wikitext.'*'

| length     = *{{Duration|m=4|s=16}} (album version)
*{{Duration|m=3|s=22}} (single version)
#>


    $parsed = $parse.parse.wikitext.'*'
    if ($parsed -match ".*\| length\s*=.*{{Duration\|(?<content>.*)}}.*") {
        $length = $matches['content']
        if (select-string 'm=' -InputObject $length) {
            [int32]$minutes = ($length.Split('|')[0]).split('=')[1]
            [int32]$seconds = ($length.Split('|')[1]).split('=')[1]
            $duration = 1000 * (($minutes * 60) + $seconds)
        }
        else {
            if (select-string ':' -InputObject $length) {
                [int32]$minutes = $length.Split(':')[0]
                [int32]$seconds = $length.Split(':')[1]
                $duration = 1000 * (($minutes * 60) + $seconds)
            }
            else {
                $duration = 0
                Write-Output "`t$length"
            }
        }
    }
    else {
        $duration = 0
    }
    Write-Output "`t$duration
    "
    $row = "" | Select-Object rank, day, start, length
    $row.rank = $missing.rank
    $row.day = $missing.day
    $row.start = $missing.start
    $row.'length' = $duration
    $gotLengths += $row

}
$gotLengths | Export-Csv -NoTypeInformation $outputFilename


