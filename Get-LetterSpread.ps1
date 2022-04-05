if ($PSScriptRoot) {
    $scriptfolder = $PSScriptRoot
}
else {
    $scriptfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}

$words = (Get-Content "$scriptfolder\5-letter-words.txt").split(" ")

$ht = @{}

foreach ($word in $words) {
    $letters = $word.ToCharArray()
    foreach ($letter in $letters) {
        if ($ht.ContainsKey($letter)) {
            $ht[$letter] += 1
        }
        else {
            $ht[$letter] = 1
        }
    }
}


foreach ($item in ($ht.GetEnumerator() | Sort-Object value -Descending)) {
    
    Write-Output "$($item.name)`t$([math]::round($item.value*100/$($words.count),0))%"

}
