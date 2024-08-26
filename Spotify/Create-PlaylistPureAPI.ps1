[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#$Rock1500_2018 = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/sound -UseBasicParsing).content | convertfrom-json)
#$Rock1500_2018 = (Get-Content '.\Full 2018.csv' | ConvertFrom-Csv)

#$Rock1500_2018 = (Get-Content ".\songs for richard.csv" | ConvertFrom-Csv)
$Rock1500_2018 = (Get-Content ".\spotify\moonsongs.csv" | ConvertFrom-Csv)


$authURL = "https://accounts.spotify.com/api/token"
$clientid = "89be3b9566f14215bc87bca0adc948ba"
$clientsecret = Get-Content .\spotifykey-makeplaylist.txt
$body = "grant_type=client_credentials"

$Bytes = [System.Text.Encoding]::Unicode.GetBytes("$($clientid):$($Clientsecret)")
$EncodedText =[Convert]::ToBase64String($Bytes)

$header = @{
    Authorization = "Basic $EncodedText"
    'Content-type' = "application/x-www-form-urlencoded"
}

$token = Invoke-RestMethod -Method Post -Uri $authURL -Body ([System.Web.HttpUtility]::UrlPathEncode($body)) -Headers $header




$clientid = "89be3b9566f14215bc87bca0adc948ba"
$redirecturl = "http://localhost:8001"
$authURL = "https://accounts.spotify.com/api/authorize?client_id=$clientid&response_type=code&redirect_uri=$redirecturl"

#region Build WinForm
Add-Type -AssemblyName System.Windows.Forms
    
$form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width = 440; Height = 640 }
$web = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width = 420; Height = 600 } #; Url = ($url -f ($Scope -join "%20"))

$DocComp = {
    $uri = $web.Url.AbsoluteUri        
    if ($uri -match "error=[^&]*|code=[^&]*") { $form.Close() }
}
$web.ScriptErrorsSuppressed = $true
$web.Add_DocumentCompleted($DocComp)
$web.url = $authURL
$form.Controls.Add($web)
$form.Add_Shown( { $form.Activate() })
$form.ShowDialog() | Out-Null

$queryOutput = [System.Web.HttpUtility]::ParseQueryString($web.Url.Query)
$output = @{}
foreach ($key in $queryOutput.Keys) {
    $output["$key"] = $queryOutput[$key]
}
#endRegion






$token = Invoke-RestMethod -Method Get -Uri $authURL 



