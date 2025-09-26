$url = "https://radio-api.mediaworks.nz/comp-api/v1/countdown/sound"

$response = invoke-restmethod $url 

$response[0]


