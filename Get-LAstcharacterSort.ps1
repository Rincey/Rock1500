$words = @(
"MICRO",
"CHURN",
"MYRRH",
"CURRY",
"HURRY",
"LORRY",
"WHIRL",
"CHIRP",
"GOURD",
"HYDRO"
)

$words | sort {$_[-1..0]}