
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
$find    = "33", "249", "4", "1", "0", "0"
$replace = "33", "249", "4", "1", "100", "0"
$replacelast = "33", "249", "4", "1", "0", "2"
$separator = " "

$newBytesJoined = $newBytes -join $separator
$findJoined = $find -join $separator
$replaceJoined = $replace -join $separator
$replaceLastJoined = $replaceLast -join $separator
$lastIndex = (select-string $findJoined -InputObject $newBytesJoined -AllMatches).matches[-1].index
$newBytesJoined = $newBytesJoined.Remove($lastIndex,$findJoined.Length)
$newBytesJoined = $newBytesJoined.insert($lastIndex,$replaceLastJoined)
$newBytesReplaced = $newBytesJoined.replace($findJoined,$replaceJoined)
[byte[]]$newArray = $newBytesReplaced -split $separator

#[byte[]]$newArray = ($newBytes -join $separator).Replace($find -join $separator, $replace -join $separator) -split $separator


[IO.file]::WriteAllBytes($filename,$newArray)      







