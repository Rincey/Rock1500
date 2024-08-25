
#download the main javascript file to collect the official list of possible wordle words
$js = Invoke-WebRequest -Uri 'https://www.nytimes.com/games-assets/v2/wordle.db510135ceb2a4c117b6.js'

#word list is found within the variable ba.  isolate and extract to $js 
$js = ($js.ParsedHtml.body.innerText -split "ba=\[")[1]
$js = ($js -split "\]")[0]

#parse the word list, usisng comma as the delimmiter and remove the double quotes
$parsedwords = $js.Split(',') -replace """"