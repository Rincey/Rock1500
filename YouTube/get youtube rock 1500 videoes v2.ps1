#requires -RunAsAdministrator
Param (
    [Parameter(Mandatory=$true)]
    [string]$inputfile,

    [Parameter(Mandatory=$true)]
    [string]$downloadfolder
)
Set-Location $PSScriptRoot

 #$inputfile = "F:\Not Shared\powershell scripts\3rdweek.csv"
 #$downloadfolder = "G:\Video Share3\New Stuff\Rock1500"

 write-host "Testing components exist..."
 if (Test-Path $inputfile) {
    write-host "`tInput file OK"
    }
    else {
    Write-Host "`tInput file not found" -ForegroundColor Red
    exit
    }

 if (Test-Path "taglib-sharp.dll") {
    write-host "`tMP3 ID3 tagging library OK"
    }
    else {
    Write-Host "`tMP3 ID3 tagging library not found.
MP3 ID3 tagging not possible without this file.
Please Google for 'taglib-sharp.dll' and download into your working folder.
(Try http://download.banshee.fm/taglib-sharp/)" -ForegroundColor Red
    exit
    }

 if ($null -ne (get-command ffmpeg.exe -ErrorAction SilentlyContinue).source) {
    write-host "`tFFMPEG OK"
    }
    else {
    Write-Host "`tFFMPEG not found.
Audio extract from videos not possible
Please Google for 'ffmpeg for windows' and download into your PATH (eg C:\windows\system32).
(Try http://ffmpeg.zeranoe.com/builds/)" -ForegroundColor Red
    exit
    }


 if ($null -ne (get-command youtube-dl.exe -ErrorAction SilentlyContinue).source) {
    write-host "`tYouTube-DL OK"
    }
    else {
    Write-Host "`tYouTube-DL not found.
Downloading of videos not possible
Please Google for 'youtube-dl for windows' and download into your PATH (eg C:\windows\system32).
(Try https://rg3.github.io/youtube-dl/download.html)" -ForegroundColor Red
    exit
    }

$countdown = Import-Csv $inputfile  -Delimiter ","
$ColumnsExpected = @(
	'artist',
	'rank',
    'title'
)

$ColumnsOK = ""

$ColumnsExpected | ForEach-Object {
	If (($countdown | Get-Member -MemberType NoteProperty).name -notcontains $_) {
		$ColumnsOK = $False
		"Expected column not found: '$($_)'" | Write-Host -ForegroundColor Red
	}
}

If ($ColumnsOK -eq $false) {
	Write-Host "The csv format is incorrect!"
    exit

    } 
    else {
    write-host "`tCSV file format OK"
    }

if ($downloadfolder.Substring(1,1) -ne ":") {
    write-host "`t$downloadfolder isn't fully qualified
Please include the full path for your download folder eg 'C:\rock1500'" -ForegroundColor Red
exit
}

if ((Get-WmiObject win32_logicaldisk -filter "DeviceID='$(($downloadfolder.Substring(0,2)))'").freespace / 1GB -lt 50) {
    write-host "`tNot enough space on $($downloadfolder.substring(0,2))
It is estimated you will need at least 50GB" -ForegroundColor Red
exit
}

if ((test-path $downloadfolder\extracted_audio) -eq $false) {
    mkdir $downloadfolder\extracted_audio |out-null
}

write-host "`tUpdating youtube-dl, if necessary"
Invoke-Expression -Command "youtube-dl -U"

$youtube = 'https://www.youtube.com' 
Unblock-File ".\taglib-sharp.dll"
[Reflection.Assembly]::LoadFrom((Resolve-Path ".\taglib-sharp.dll")) |out-null

 foreach ($line in $countdown) {
 $searchTerm = ($line.title -replace " ","+") + "+" + ($line.artist -replace " ","+")
 $youTubePage = "$youtube" + "/results?search_query=" + $searchTerm
 $web = Invoke-WebRequest -Uri "$youTubePage"
 $allLinks = New-Object System.Collections.ArrayList
 foreach($link in $web.Links)
      {
       if($searchTerm -like "*cover*") {
 $a = ($web.Links |?{($_.href -like '*/watch?v=*') -and 
      ($_.href -notlike '*list=*') -and
      (($_.innerText -like "*official*") -or ($_.innerText -notlike "*album*")) -and
      ($_.innerText -notlike "*:*") -and
      ($_.innerText -notlike "*lyrics*")})
      }
    else
    {
 $a = ($web.Links |?{($_.href -like '*/watch?v=*') -and 
      ($_.href -notlike '*list=*') -and
      (($_.innerText -like "*official*") -or ($_.innerText -notlike "*album*")) -and
      ($_.innerText -notlike "*:*") -and
      ($_.innerText -notlike "*lyrics*") -and
      ($_.innerText -notlike "*cover*")})
    }         
       
         $url = $youtube + $a.href  
         $linkEntry = "$($line.rank) ; $($line.artist) ; $($line.title) ; $url ; $($a.innerText) "
         [void]$allLinks.Add($linkEntry)
}      
      


$YTargs = $allLinks[0] -split ";"
$position = $YTargs[0].trim()
$position = ($position.PadLeft(4,"0")).trim()
$artist = $YTargs[1].trim()
$song = $YTargs[2].Trim()
$YTurl = $YTargs[3].trim()

$filename = "$position - $artist - $song"
$filename = $filename.replace("<","_")
$filename = $filename.replace(">","_")
$filename = $filename.replace(":","-")
$filename = $filename.replace("""","'")
$filename = $filename.replace("/","_")
$filename = $filename.replace("\","_")
$filename = $filename.replace("|","-")
$filename = $filename.replace("?","^")
$filename = $filename.replace("*","^")

$command = "youtube-dl -o `"$downloadfolder\$filename.mp4`" -f best `"$YTurl`" -x -k --audio-format mp3"
#$command
#
Invoke-Expression -Command $command

Move-Item "$downloadfolder\$filename.mp3" "$downloadfolder\extracted_audio"
$mp3 = [TagLib.File]::Create((resolve-path "$downloadfolder\extracted_audio\$filename.mp3"))
$mp3.Tag.Album = "The Rock 1500 2017"
$mp3.Tag.Year = "2017"
$mp3.Tag.Title = $song
$mp3.Tag.Track = $position
$mp3.Tag.Performers = $artist
$mp3.Save()
#>

}