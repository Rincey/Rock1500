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

$data = $hash.GetEnumerator() | Sort-Object name 

Add-Type -AssemblyName System.Drawing

#set up graphic variables
$bmp = new-object System.Drawing.Bitmap 1000, 500 
$fontSize = 24
$font = new-object System.Drawing.Font Arial, $fontSize 
$brushBg = [System.Drawing.Brushes]::White 
$brushFg = [System.Drawing.Brushes]::Black 
$brushRed = [System.Drawing.Brushes]::Red
$brushBlue = [System.Drawing.Brushes]::Blue

$graphTitle = "Album Year Spread"
$titleSize = [System.Windows.Forms.TextRenderer]::MeasureText($graphTitle, $font)
$pen = New-Object System.Drawing.Pen $brushFg, 2
$axisFontSize = 16 
$axisFont = new-object System.Drawing.Font Arial, $axisFontSize 
$yAxisSize = [System.Windows.Forms.TextRenderer]::MeasureText("888", $axisFont)
$xAxisSize = [System.Windows.Forms.TextRenderer]::MeasureText("8888", $axisFont)

#set up graph
$graphics = [System.Drawing.Graphics]::FromImage($bmp) 
$graphics.FillRectangle($brushBg, 0, 0, $bmp.Width, $bmp.Height) 

#Draw title
$graphics.DrawString($graphTitle, 
    $font, 
    $brushFg, 
    ($bmp.Width - $titleSize.width) / 2, 
    10)


#draw axis lines

#y-axis
$graphics.DrawLine(
    $pen, 
    $yAxisSize.Width + 10, 
    $titleSize.Height, 
    $yAxisSize.width + 10, 
    $bmp.Height - $xAxisSize.width
)

#x-axis
$graphics.DrawLine(
    $pen, 
    $yAxisSize.width + 10, 
    $bmp.Height - $xAxisSize.width, 
    $bmp.Width - $y2AxisSize.width - 10, 
    $bmp.Height - $xAxisSize.width
)


#draw Y axis values & tick marks
$yTick = 2

$maxYvalue = ($data.value | Measure-Object  -Maximum).Maximum
$maxYvalue = $maxYvalue + ($yTick - ($maxYvalue % $yTick))

$minYvalue = ($data.value | Measure-Object  -Minimum).Minimum
$minYvalue = $minYvalue - ($minYvalue % $yTick)

$yStep = 5
for ($i = 0; $i -le $yStep; $i++) {
    $graphics.DrawString(
        [int]($minYvalue + $i * ($maxYvalue - $minYvalue) / $yStep), 
        $axisfont, 
        $brushFg, 
        [int]($yAxisSize.Width `
                - [System.Windows.Forms.TextRenderer]::MeasureText([int]($minYvalue + $i * ($maxYvalue - $minYvalue) / $yStep), $axisFont).width), 
        [int](($bmp.Height - $xAxisSize.Width) - $i * ($bmp.Height - $xAxisSize.Width - $titleSize.Height) / $yStep) `
            - [System.Windows.Forms.TextRenderer]::MeasureText($minYvalue + $i * ($maxYvalue - $minYvalue) / $yStep, $axisFont).height / 2
    )
    $graphics.DrawLine(
        $pen, 
        $yAxisSize.Width + 10 - 4, 
        [int](($bmp.Height - $xAxisSize.Width) - $i * ($bmp.Height - $xAxisSize.Width - $titleSize.Height) / $yStep), 
        $yAxisSize.width + 10 + 4, 
        [int](($bmp.Height - $xAxisSize.Width) - $i * ($bmp.Height - $xAxisSize.Width - $titleSize.Height) / $yStep)
    )
}


#get date string into datetime & reverse order (oldest first) of data
#foreach ($secureScore in $secureScores) {
#    [datetime]$securescore.createdDateTime = [datetime]::ParseExact($secureScore.createdDateTime, 'yyyy-MM-ddTHH:mm:ssZ', $null) 
#}
#[array]::Reverse($SecureScores)

[int]$maxXvalue = $data[-1].name
[int]$minXvalue = $data[0].name

$xRange = $maxXvalue - $minXvalue

#draw X axis values, and tick marks
#
# THIS SECTION NEEDS REWORK - HISTOGRAM NOW, NOT TIME SERIES
#
$xStep = 2
$i = 0
$xLabel = $minXvalue + ($i * $xRange / $xStep) 
$graphics.DrawString(
    $xlabel, 
    $axisfont, 
    $brushFg, 
    [int](($yAxisSize.Width + $i * ($bmp.Width - 10 - $yAxisSize.Width - $y2AxisSize.width) / $xStep)), 
    [int](($bmp.Height - $xAxisSize.Width) + 10)
)
$graphics.DrawLine(
    $pen, 
    $yAxisSize.Width + 10, 
    $bmp.Height - $xAxisSize.width - 4, 
    $yAxisSize.Width + 10, 
    $bmp.Height - $xAxisSize.width + 4
)
    
$i++
$xLabel = get-date $minXvalue.AddDays($i * $xRange / $xStep) -Format "dd-MM-yyyy"
$graphics.DrawString(
    $xlabel, 
    $axisfont, 
    $brushFg, 
    [int](($yAxisSize.Width + $i * ($bmp.Width - 10 - $yAxisSize.Width - $y2AxisSize.width) / $xStep) `
            - [System.Windows.Forms.TextRenderer]::MeasureText($xLabel, $axisFont).width / 2), 
    [int](($bmp.Height - $xAxisSize.Width) + 10)
)
$graphics.DrawLine(
    $pen, 
    [int]($yAxisSize.Width + $i * ($bmp.Width - 10 - $yAxisSize.Width - $y2AxisSize.width) / $xStep), 
    $bmp.Height - $xAxisSize.width - 4, 
    [int]($yAxisSize.Width + $i * ($bmp.Width - 10 - $yAxisSize.Width - $y2AxisSize.width) / $xStep), 
    $bmp.Height - $xAxisSize.width + 4
)

$i++
$xLabel = get-date $minXvalue.AddDays($i * $xRange / $xStep) -Format "dd-MM-yyyy"
$graphics.DrawString(
    $xlabel, 
    $axisfont, 
    $brushFg, 
    [int](($yAxisSize.Width + $i * ($bmp.Width - 10 - $yAxisSize.Width - $y2AxisSize.width) / $xStep) `
            - [System.Windows.Forms.TextRenderer]::MeasureText($xLabel, $axisFont).width), 
    [int](($bmp.Height - $xAxisSize.Width) + 10)
)
$graphics.DrawLine(
    $pen, 
    [int]($yAxisSize.Width + $i * ($bmp.Width - 10 - $yAxisSize.Width - $y2AxisSize.width) / $xStep), 
    $bmp.Height - $xAxisSize.width - 4, 
    [int]($yAxisSize.Width + $i * ($bmp.Width - 10 - $yAxisSize.Width - $y2AxisSize.width) / $xStep), 
    $bmp.Height - $xAxisSize.width + 4
)


$currPen = New-Object System.Drawing.Pen $brushRed, 1


#draw data points as small circles, & capture points into array
foreach ($item in $data) {
    $xFraction = ([int]$item.name - $minXvalue) / $xRange
    $xPos = $xFraction * ($bmp.Width - $yAxisSize.Width - 20 - $y2AxisSize.width) + $yAxisSize.Width + 10

    $yCurrFraction = ([int]$item.value - $minYvalue) / ($maxYvalue - $minYvalue)
    $yCurrPos = $yCurrFraction * ($titleSize.Height - ($bmp.Height - $xAxisSize.Width)) + ($bmp.Height - $xAxisSize.Width)

    [single]$pointWidth = 4
    [single]$pointHeight = $pointWidth

  #
  # REWORK HERE. COLUMNS NOT POINTS
  #  
    $graphics.DrawEllipse(
        $currPen,
        [single]$xPos - $pointWidth / 2,
        [single]$yCurrPos - $pointHeight / 2,
        [single]$pointWidth,
        [single]$pointHeight
    )

}


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
