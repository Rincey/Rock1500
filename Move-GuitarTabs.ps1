$rootFolder = "E:\Downloads\whatbox\Guitar Tabs\Guitar Pro Tabs"
$folders = get-childitem -path $rootFolder -Directory
foreach ($folder in $folders) {
$tabs = Get-ChildItem -path "$rootFolder\$($folder.name)" -File
foreach ($tab in $tabs) {
    $tab.Name
    $artist = $tab.name.split("-")[0].trim()
    if (!(test-path "$rootFolder\$($folder.name)\$artist")) {
        New-Item -Path $rootFolder\$($folder.name) -Name $artist -ItemType Directory -Force
    }
    $source = $tab.FullName
    $dest = "$rootFolder\$($folder.name)\$artist\$($tab.name)"
    Move-Item -path $([wildcardpattern]::escape($source)) -Destination $([wildcardpattern]::escape($dest)) -Force
}

}