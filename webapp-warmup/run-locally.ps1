Write-Verbose "Entering script run-locally.ps1"

$rootUrl = "https://google.com"
$retryCount = 2
$sleepPeriod = 1
$ignoreError = $false
$ignoreSslError = $false
$suffixes = "/
/mail
fail"

.\webapp-warmup.ps1  -rootUrl $rootUrl -retryCount $retryCount -sleepPeriod $sleepPeriod -ignoreError $ignoreError -suffixes $suffixes -ignoreSslError $ignoreSslError