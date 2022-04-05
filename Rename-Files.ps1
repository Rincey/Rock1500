$workingFolder = 'E:\Working Photos for TIme Lapse\2022-02-09'
$files = Get-ChildItem -path $workingFolder -File |sort-object Name

foreach ($file in $files) {
    $i = [array]::IndexOf($files, $file) + 1
    [string]$newName = "$workingfolder\$(([string]$i).PadLeft(5,'0')).jpg"
    move-item -path $file.FullName -Destination $newName

}