$days = 1..9

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
[IO.file]::WriteAllBytes($filename,$newBytes)      







