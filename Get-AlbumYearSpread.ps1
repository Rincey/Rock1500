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
$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/therock -UseBasicParsing).content | convertfrom-json)
#$AlreadyPlayed = ((Invoke-WebRequest https://radio-api.mediaworks.nz/comp-api/v1/countdown/sound -UseBasicParsing).content | convertfrom-json)

$hash = @{}

foreach ($track in $AlreadyPlayed) {
    $year = $track.albumyear
    if ($hash.ContainsKey($year)) {
        $hash.$year += 1
    }
    else {
        $hash.$year = 1
    }
}

$data = $hash.GetEnumerator() | Where-Object name -ne '' | Sort-Object name 

$yStep = 5
$maxYvalue = ($data.value | Measure-Object  -Maximum).Maximum
$maxYvalue = $maxYvalue + ($yStep - ($maxYvalue % $ystep))
$minYvalue = 0

$xStep = 2
[int]$maxXvalue = $data[-1].name 
[int]$minXvalue = $data[0].name 
$maxXvalue = $maxXvalue + 1
$minXvalue = $minXvalue - 1

$xRange = $maxXvalue - $minXvalue

$alreadyplayed | ForEach-Object {
    $_ | Add-Member -MemberType NoteProperty -Name Day -Value (Get-TotalWeekDays -Start $($AlreadyPlayed[-1].timestamp.split(" ")[0]) -End $($_.timestamp.split(" ")[0]))
}
$days = $AlreadyPlayed | Select-Object  -ExpandProperty day -Unique | Sort-Object 
foreach ($day in $days) {
    $countdown = $AlreadyPlayed | Where-Object { [int32]$_.day -le [int32]$day }

    $hash = @{}

    foreach ($track in $countdown) {
        $year = $track.albumyear
        if ($hash.ContainsKey($year)) {
            $hash.$year += 1
        }
        else {
            $hash.$year = 1
        }
    }

    $data = $hash.GetEnumerator() | Where-Object name -ne '' | Sort-Object name 

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

    $graphTitle = "Album Year"
    $frameTitle = "Day $(([string]$day).padleft(2," "))"
    $framefontSize = 8
    $framefont = new-object System.Drawing.Font CourierNew, $framefontSize 
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

    # draw frame label
    $graphics.DrawString($frameTitle, 
        $framefont, 
        $brushFg, 
        10, 
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

 

}

start-sleep -Seconds 5

if ($PSScriptRoot) {
    $reportfolder = $PSScriptRoot
}
else {
    $reportfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}
$filename = "$reportfolder\animated-album-years.gif"


Add-Type -AssemblyName PresentationCore
add-type -AssemblyName system.drawing
$gif = New-Object -TypeName System.Windows.Media.Imaging.GifBitmapEncoder


foreach ($frame in Get-ChildItem "$reportfolder\image-*.gif") {
    $bmp = [System.Drawing.Bitmap]::FromFile($frame.fullname)
    $hbmp = $bmp.GetHbitMap()
    $bmpsrc = [System.Windows.Interop.Imaging]::CreateBitmapSourceFromHBitmap($hbmp, `
            [System.IntPtr]::Zero, `
            'Empty', `
            [System.Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions()`
    )
    $gif.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($bmpsrc))
    $hbmp = $bmp = $null
}


$MemoryStream = New-Object System.IO.MemoryStream
$gif.save($MemoryStream)
$Bytes = $MemoryStream.ToArray()
$applicationExtension = [byte[]](33, 255, 11, 78, 69, 84, 83, 67, 65, 80, 69, 50, 46, 48, 3, 1, 0, 0, 0 )
$newBytes = New-Object -TypeName 'System.Collections.Generic.List[byte]'
$newBytes.AddRange([byte[]]$bytes[0..12]);
$newBytes.AddRange($applicationExtension);
$newBytes.AddRange([byte[]]$bytes[13..($bytes.count)])

<# 
DELAY 
Hex: 21  f9 04 01 00 00
Dec: 33 249 04 01 00 00
change to
Hex: 21  f9 04 01  c8 00 (2 seconds)
Dec: 33 249 04 01 200 00
Dec: 33 249 04 01 00 02 (5.12 sec)
#>
$find = "33", "249", "4", "1", "0", "0"
$replace = "33", "249", "4", "1", "100", "0"
$replacelast = "33", "249", "4", "1", "0", "2"
$separator = " "

$newBytesJoined = $newBytes -join $separator
$findJoined = $find -join $separator
$replaceJoined = $replace -join $separator
$replaceLastJoined = $replaceLast -join $separator
$lastIndex = (select-string $findJoined -InputObject $newBytesJoined -AllMatches).matches[-1].index
$newBytesJoined = $newBytesJoined.Remove($lastIndex, $findJoined.Length)
$newBytesJoined = $newBytesJoined.insert($lastIndex, $replaceLastJoined)
$newBytesReplaced = $newBytesJoined.replace($findJoined, $replaceJoined)
[byte[]]$newArray = $newBytesReplaced -split $separator

#[byte[]]$newArray = ($newBytes -join $separator).Replace($find -join $separator, $replace -join $separator) -split $separator


[IO.file]::WriteAllBytes($filename, $newArray)      


Remove-Item "$reportfolder\image-*.gif"


