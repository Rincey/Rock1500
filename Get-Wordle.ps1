if ($PSScriptRoot) {
    $scriptfolder = $PSScriptRoot
}
else {
    $scriptfolder = $psEditor.GetEditorContext().CurrentFile.Path.replace($psEditor.GetEditorContext().CurrentFile.Path.split("\")[-1], "")
}

$words = (Get-Content "$scriptfolder\5-letter-words.txt").split(" ")

<#
1 = not there
2 = wrong position
3 = right position
"BREAD",1,1,1,1,1
"SPOUT",1,1,2,1,1
"MILKY",1,2,1,1,1
"GOING",1,3,2,2,1
"IONIC",3,3,3,3,3
#>


$guess = "BREAD",1,1,1,1,1

$letters = $guess[0].tochararray()
foreach ($word in $words){
    
}
