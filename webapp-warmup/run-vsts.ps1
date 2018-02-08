Write-Verbose "Entering script run-vsts.ps1"

$rootUrl = Get-VstsInput -Name Url
$retryCount = Get-VstsInput -Name RetryCount
$sleepPeriod = Get-VstsInput -Name SleepPeriod
$ignoreError = Get-VstsInput -Name IgnoreError
$suffixes = Get-VstsInput -Name Suffixes

.\webapp-warmup.ps1  -rootUrl $rootUrl -retryCount $retryCount -sleepPeriod $sleepPeriod -ignoreError $ignoreError -suffixes $suffixes