##### Get through proxy if necessary
(New-Object System.Net.WebClient).Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

$youtube = 'https://www.youtube.com' 
$line = "" | select title,artist
$line.title = "Hardwired"
$line.artist = "Metallica"

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
      ($_.innerHTML -notlike "*yt-thumb video-thumb*") -and
      ($_.innerText -notlike "*lyrics*")})
      }
    else
    {
 $a = ($web.Links |?{($_.href -like '*/watch?v=*') -and 
      ($_.href -notlike '*list=*') -and
      (($_.innerText -like "*official*") -or ($_.innerText -notlike "*album*")) -and
      ($_.innerHTML -notlike "*yt-thumb video-thumb*") -and
      ($_.innerText -notlike "*lyrics*") -and
      ($_.innerText -notlike "*cover*")})
    }         
       
         $url = $youtube + $a.href  
         $linkEntry = "$($line.rank) ; $($line.artist) ; $($line.title) ; $url ; $($a.innerText) "
         [void]$allLinks.Add($linkEntry)
}      
      
