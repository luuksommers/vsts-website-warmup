Write-Verbose "Entering script run-vsts.ps1"

$rootUrl = Get-VstsInput -Name Url
$retryCount = Get-VstsInput -Name RetryCount -AsInt
$sleepPeriod = Get-VstsInput -Name SleepPeriod -AsInt
$ignoreError = Get-VstsInput -Name IgnoreError -AsBool
$ignoreSslError = Get-VstsInput -Name IgnoreSslError -AsBool
$suffixes = Get-VstsInput -Name Suffixes
$basicAuthUser = Get-VstsInput -Name BasicAuthUser
$basicAuthPassword = Get-VstsInput -Name BasicAuthPassword

.\website-warmup.ps1 -rootUrl $rootUrl -retryCount $retryCount -sleepPeriod $sleepPeriod -ignoreError $ignoreError -suffixes $suffixes -ignoreSslError $ignoreSslError -basicAuthUser $basicAuthUser -basicAuthPassword $basicAuthPassword