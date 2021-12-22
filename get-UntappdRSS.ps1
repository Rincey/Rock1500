
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}
$filename = "$reportfolder\..\untappdkey.txt"
$key = Get-Content $filename

$url = "https://untappd.com/rss/user/Rincey?key=$key"

$result = Invoke-RestMethod `
    -Uri $url `
    -Method get 

$regex = @"
<div class="caps" data-rating=".*">
"@

foreach ($link in $result) {

    $checkinurl = $link.link
    $checkinresult = Invoke-RestMethod `
        -Uri $checkinurl `
        -Method get 


    if ($checkinresult -match $regex) {
        $rating = $matches[0].split("=")[2].split("`"")[1]
    }
    else {
        $rating = "No Rating"
    }

    $beer = $link.title -replace "Scott w. is drinking ", ""
    $beer = $beer -replace " at Untappd at Home", ""
    $date = get-date ($link.pubDate) -Format "dd/MM/yyyy"
    Write-Output "$date,$beer,$rating"

} 


