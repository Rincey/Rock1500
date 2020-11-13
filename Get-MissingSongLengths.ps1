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

$result = Invoke-RestMethod -Method get -Uri "https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=fat%20bottomed%20girls&utf8=&format=json"
$parse = Invoke-RestMethod -Method Get -Uri "https://en.wikipedia.org/w/api.php?action=parse&pageid=3957378&prop=wikitext&format=json"

$parsed = $parse.parse.wikitext.'*'
if ($parsed -match ".*\| length\s*=\s*\*{{Duration\|(?<content>.*)}}.*") {
    $length = $matches['content']
    [int32]$minutes = ($length.Split('|')[0]).split('=')[1]
    [int32]$seconds = ($length.Split('|')[1]).split('=')[1]
    $duration = 1000 * (($minutes * 60) + $seconds)
}


<#
$parse.parse.wikitext.'*'

| length     = *{{Duration|m=4|s=16}} (album version)
*{{Duration|m=3|s=22}} (single version)
#>

