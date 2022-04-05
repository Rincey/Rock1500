$taglibpath = "C:\Program Files\PackageManagement\NuGet\Packages\TagLibSharp.2.2.0\lib\net45\TagLibSharp.dll"
[System.Reflection.Assembly]::LoadFrom($taglibpath)

$filePath = "E:\FromMediaServer\Share\Media\Audio\mp3s\Goons\"
$files = Get-ChildItem -path $filepath -File | sort-object Name
$regex = ".*\s(?'seriesepisode'\d\d-\d\d)\s.*"

foreach ($file in $files) {

    if ($file.name -match $regex) {

        $seriesEpisode = $Matches['seriesepisode']
        $artist = ($file.name -split ($seriesEpisode))[0] -replace ".{3}$"
        $title = ($file.name -split ($seriesEpisode))[1] -replace "^.{3}" -replace $file.extension

        $series = $seriesEpisode.split("-")[0]
        $episode = $seriesEpisode.split("-")[1]


        $tag = [TagLib.File]::Create($file.FullName)

        $tag.Tag.title = $title
        $tag.tag.Album = "Series $series"
        $tag.tag.Artists = $artist
        $tag.tag.Track = $episode

        $tag.Save()
        if (!(test-path "$filepath\Series $series")) {
            mkdir "$filepath\Series $series"
        }
        Move-Item -path $file.FullName -Destination "$filepath\Series $series\$($file.name)"
    }
}