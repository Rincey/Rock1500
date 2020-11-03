[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$rawcountdown = (Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | 
ConvertFrom-Json

    
$countdown = $rawcountdown 
$topnumber = 20
$topTen = $countdown |
Group-Object artist |
sort-object count -Descending
    
$data = $topten | 
Where-Object { $_.count -ge $topten[$topnumber - 1].count } | 
Select-Object Name, Count  


$total = 0
foreach ($item in $data){
    $total += $item.Count
}
Add-Type -AssemblyName System.Drawing
add-type -AssemblyName system.windows.Forms

#set up graphic variables

$bmp = new-object System.Drawing.Bitmap 1000, 500 
$fontSize = 24
$font = new-object System.Drawing.Font Arial, $fontSize 
$brushBg = [System.Drawing.Brushes]::White 
$brushFg = [System.Drawing.Brushes]::Black 

$graphTitle = "Top $topnumber Artists"
$titleSize = [System.Windows.Forms.TextRenderer]::MeasureText($graphTitle, $font)
$pen = New-Object System.Drawing.Pen $brushFg, 2

$brushes = @(
    [System.Drawing.Brushes]::Maroon,
    [System.Drawing.Brushes]::Red,
    [System.Drawing.Brushes]::Purple,
    [System.Drawing.Brushes]::Fuchsia,
    [System.Drawing.Brushes]::Green,
    [System.Drawing.Brushes]::Lime,
    [System.Drawing.Brushes]::Gold,
    [System.Drawing.Brushes]::Navy,
    [System.Drawing.Brushes]::Blue,
    [System.Drawing.Brushes]::Teal,
    [System.Drawing.Brushes]::Aqua,
    [System.Drawing.Brushes]::Orange,
    [System.Drawing.Brushes]::Chocolate,
    [System.Drawing.Brushes]::CornflowerBlue,
    [System.Drawing.Brushes]::Cornsilk,
    [System.Drawing.Brushes]::Crimson,
    [System.Drawing.Brushes]::OrangeRed,
    [System.Drawing.Brushes]::YellowGreen,
    [System.Drawing.Brushes]::Salmon,
    [System.Drawing.Brushes]::SeaGreen,
    [System.Drawing.Brushes]::Sienna,
    [System.Drawing.Brushes]::Tan,
    [System.Drawing.Brushes]::Thistle,
    [System.Drawing.Brushes]::Violet

)




#set up graph
$graphics = [System.Drawing.Graphics]::FromImage($bmp) 
$graphics.FillRectangle($brushBg, 0, 0, $bmp.Width, $bmp.Height) 

#Draw title
$graphics.DrawString($graphTitle, 
    $font, 
    $brushFg, 
    ($bmp.Width - $titleSize.width) / 2, 
    10)




$pieWidth = $bmp.Width / 2
$pieHeight = $bmp.Height - $titleSize.Height - 10
$pieX = $bmp.Width / 2
$pieY = $titleSize.Height + 10
$pieLegendfontSize = 12
$pieLegendfont = new-object System.Drawing.Font Arial, $pieLegendfontSize 

[int32]$startAngle = 0
$pieLegendY = $titleSize.Height + 10

foreach ($item in $data) {

    [int32]$endAngle = 360 * $item.Count / $total
if ($startAngle + $endAngle -gt 360) {
    $endAngle = 360 - $startAngle
}
    $graphics.FillPie( 
    $Brushes[[array]::IndexOf($data,$item)],
    $pieX,
    $pieY,
    $pieWidth,
    $pieHeight,
    $startAngle,
    $endAngle
)
$startAngle = $startAngle + $endAngle
$legendText = "$($item.name) ($($item.count))"
$graphics.DrawString($legendText, 
    $pieLegendfont, 
    $Brushes[[array]::IndexOf($data,$item)], 
    10, 
    $pieLegendY)

    $pieLegendY = $pieLegendY + ([System.Windows.Forms.TextRenderer]::MeasureText($legendText, $pielegendfont)).height + 5

}
#>

$graphics.Dispose() 


#output bmp object to base64 string into html code
#
# EITHER OUTPUT TO CLIPBOARD OR FILE, OR DISPLAY TO SCREEN?
#
$MemoryStream = New-Object System.IO.MemoryStream
$bmp.save($MemoryStream, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$Bytes = $MemoryStream.ToArray()
$MemoryStream.Flush()
$MemoryStream.Dispose()

$imgB64 = [convert]::ToBase64String($Bytes)

$testhtml = @"
<html><head><title>Test bitmap</title></head>
<body>
<img src="data:image/png;base64,$imgB64">
</body>
</html>
"@


if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}
$testhtml | Out-File "$reportfolder\testgraphic.html"
