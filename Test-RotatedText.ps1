Add-Type -AssemblyName System.Drawing

#set up graphic variables
$bmp = new-object System.Drawing.Bitmap 1500, 500 
$fontSize = 24
$font = new-object System.Drawing.Font Arial, $fontSize 
$brushBg = [System.Drawing.Brushes]::White 
$brushFg = [System.Drawing.Brushes]::Black 
$brushRed = [System.Drawing.Brushes]::Red
$brushBlue = [System.Drawing.Brushes]::Blue

$graphTitle = "Album Year Spread"
$titleSize = [System.Windows.Forms.TextRenderer]::MeasureText($graphTitle, $font)
$pen = New-Object System.Drawing.Pen $brushFg, 2
$axisFontSize = 12 
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


# new text stuff
$minXvalue = 1965 - 1
$maxXvalue = 2020 + 1

for ($label = $minXvalue; $label -lt $maxXvalue; $label+=2) {
    $labelH = [System.Windows.Forms.TextRenderer]::MeasureText($label, $axisFont).Height
    $labelW = [System.Windows.Forms.TextRenderer]::MeasureText($label, $axisFont).width
    $textBmp = new-object System.Drawing.Bitmap $labelH, $labelW 
    #$textgraphics.TranslateTransform($labelH,0)
    $textGraphics = [System.Drawing.Graphics]::FromImage($textbmp) 
    $textGraphics.RotateTransform(90)
    
    $textGraphics.DrawString(
        $label,
        $axisFont,
        $brushFg,
        0,
        - $labelH
    )


    #
    $labelx = $yAxisSize.Width + 10 + ($label - $minXvalue) / ($maxXvalue - $minXvalue) * ($bmp.Width - $y2AxisSize.width - 10 - $yAxisSize.width - 10)
    $labely = $bmp.Height - $xAxisSize.width
    <#

$currPen = New-Object System.Drawing.Pen $brushRed, 1

$graphics.DrawRectangle(
    $currPen,
    $labelx,
    $labely,
    $labelH,
    $labelW
)
#>

    $graphics.DrawImage($textBmp, $labelx, $labely)
}

$MemoryStream = New-Object System.IO.MemoryStream
$bmp.save($MemoryStream, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$Bytes = $MemoryStream.ToArray()
$MemoryStream.Flush()
$MemoryStream.Dispose()
$textGraphics.Dispose()
$graphics.Dispose()
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
