Write-Verbose "Entering script run-vsts.ps1"

$rootUrl = Get-VstsInput -Name Url
$retryCount = Get-VstsInput -Name RetryCount -AsInt
$sleepPeriod = Get-VstsInput -Name SleepPeriod -AsInt
$ignoreError = Get-VstsInput -Name IgnoreError -AsBool
$suffixes = Get-VstsInput -Name Suffixes

.\webapp-warmup.ps1  -rootUrl $rootUrl -retryCount $retryCount -sleepPeriod $sleepPeriod -ignoreError $ignoreError -suffixes $suffixes