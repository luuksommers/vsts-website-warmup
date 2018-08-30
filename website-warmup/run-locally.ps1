Write-Verbose "Entering script run-locally.ps1"

$rootUrl = "https://google.com"
$retryCount = 2
$sleepPeriod = 1
$ignoreError = $false
$ignoreSslError = $false
$suffixes = "/
/mail
fail"
$basicAuthUser = ""
$basicAuthPassword = ""

# .\website-warmup.ps1  -rootUrl $rootUrl -retryCount $retryCount -sleepPeriod $sleepPeriod -ignoreError $ignoreError -suffixes $suffixes -ignoreSslError $ignoreSslError  -basicAuthUser $basicAuthUser -basicAuthPassword $basicAuthPassword

$basicAuthUser = "guest"
$basicAuthPassword = "guest"
$rootUrl = "https://jigsaw.w3.org"
$suffixes = "/HTTP/Basic/"

.\website-warmup.ps1 -rootUrl $rootUrl -suffixes $suffixes -basicAuthUser $basicAuthUser -basicAuthPassword $basicAuthPassword

$basicAuthPassword = "guest1"

.\website-warmup.ps1 -rootUrl $rootUrl -suffixes $suffixes -basicAuthUser $basicAuthUser -basicAuthPassword $basicAuthPassword
