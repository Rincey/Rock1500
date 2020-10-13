$rootFolder = "E:\GuitarPro_Tabs"
$tabs = Get-ChildItem -path $rootFolder -File
foreach ($tab in $tabs) {
    $tab.Name
    $artist = $tab.name.split("-")[0].trim()
    if (!(test-path "$rootFolder\$artist")) {
        New-Item -Path $rootFolder -Name $artist -ItemType Directory -Force
    }
    $source = $tab.FullName
    $dest = "$rootFolder\$artist\$($tab.name)"
    Move-Item -path $([wildcardpattern]::escape($source)) -Destination $([wildcardpattern]::escape($dest)) -Force
}

