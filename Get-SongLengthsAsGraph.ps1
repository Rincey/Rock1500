Function Get-TotalWeekDays {
    [cmdletbinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "What is the start date?")]
        [ValidateNotNullorEmpty()]
        [DateTime]$Start,
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "What is the end date?")]
        [ValidateNotNullorEmpty()]
        [DateTime]$End
    )
  
    $i = 0
    for ($d = $Start; $d -le $end; $d = $d.AddDays(1)) {
        if ($d.DayOfWeek -notmatch "Sunday|Saturday") {
            $i++    
        }
    } 
    return    $i
} 

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}


$filename = "$reportfolder\songlengths.csv"
$AlreadyPlayed = Import-Csv $filename

$hash = @{}

$data = $AlreadyPlayed | Where-Object day -eq 1 | Sort-Object -Descending rank


$yStep = 1
$maxYvalue = $data.Count
$minYvalue = 0

$xStep = 2
$maxXvalue = ((get-date $data[-1].start)  - (get-date $data[0].start )).totalmilliseconds + $data[-1].length
[int]$minXvalue = 0 

$xRange = $maxXvalue - $minXvalue


    Add-Type -AssemblyName System.Drawing
    add-type -AssemblyName system.windows.Forms

    #set up graphic variables
    $bmp = new-object System.Drawing.Bitmap 1000, 500 
    $fontSize = 24
    $font = new-object System.Drawing.Font Arial, $fontSize 
    $brushBg = [System.Drawing.Brushes]::White 
    $brushFg = [System.Drawing.Brushes]::Black 
    $brushRed = [System.Drawing.Brushes]::Red
    $brushBlue = [System.Drawing.Brushes]::Blue

    $graphTitle = "Song times"
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




    #draw X axis values, and tick marks
    #
    # THIS SECTION NEEDS REWORK - HISTOGRAM NOW, NOT TIME SERIES
    #
 

    for ($label = $minXvalue; $label -lt $maxXvalue; $label += $xStep) {
        $labelH = [System.Windows.Forms.TextRenderer]::MeasureText($label, $axisFont).Height
        $labelW = [System.Windows.Forms.TextRenderer]::MeasureText($label, $axisFont).width
        $textBmp = new-object System.Drawing.Bitmap $labelH, $labelW 
         
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
        $labelx = $yAxisSize.Width + 10 + ($label - $minXvalue) / ($xRange) * ($bmp.Width - 20 - $yAxisSize.width )
        $labely = $bmp.Height - $xAxisSize.width
 

        $graphics.DrawImage($textBmp, $labelx, $labely)
    }

    #
    #draw data points as small circles, & capture points into array

    foreach ($item in $data) {
        $xFraction = ([int]$item.name - $minXvalue) / $xRange
        $xPos = $xFraction * ($bmp.Width - $yAxisSize.Width - 20 ) + $yAxisSize.Width + 10 + $labelh / 2

        $yCurrFraction = ([int]$item.value - $minYvalue) / ($maxYvalue - $minYvalue)
        $yCurrPos = $yCurrFraction * ($titleSize.Height - ($bmp.Height - $xAxisSize.Width)) + ($bmp.Height - $xAxisSize.Width)

        [single]$pointWidth = 4
        if ($item.value -eq ($data.value | Measure-Object  -Maximum).Maximum) {
            $bar = $brushRed
        }
        else {
            $bar = $brushBlue
        }
        #
        # REWORK HERE. COLUMNS NOT POINTS
        #  
        $graphics.FillRectangle(
            $bar,
            [single]$xPos - $pointWidth / 2,
            [single]$yCurrPos,
            [single]$pointWidth,
            [single]$bmp.Height - $xAxisSize.width - $yCurrPos
        )

    }
    #>

    $graphics.Dispose() 


    #output bmp object to base64 string into html code
    #
    # EITHER OUTPUT TO CLIPBOARD OR FILE, OR DISPLAY TO SCREEN?
    #

    if ($PSScriptRoot) {
        $reportfolder = $PSScriptRoot
    }
    else {
        $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
    }

 
    $filename = "$reportfolder\image-$(([string]$day).padleft(2,"0")).gif"

    $fileStream = New-Object System.IO.FileStream $filename, 'Create'

    $bmp.save($fileStream, [System.Drawing.Imaging.ImageFormat]::Gif)
    #$Bytes = $MemoryStream.ToArray()
    $fileStream.Flush()
    $fileStream.Dispose()

    <#
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
#>

}
