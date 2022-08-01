Write-Verbose "Entering script run-vsts.ps1"

$rootUrls = Get-VstsInput -Name Urls
$retryCount = Get-VstsInput -Name RetryCount -AsInt
$sleepPeriod = Get-VstsInput -Name SleepPeriod -AsInt
$ignoreError = Get-VstsInput -Name IgnoreError -AsBool
$ignoreSslError = Get-VstsInput -Name IgnoreSslError -AsBool
$suffixes = Get-VstsInput -Name Suffixes
$authMethod = Get-VstsInput -Name Authentication
$user = Get-VstsInput -Name User
$password = Get-VstsInput -Name Password
$timeout = Get-VstsInput -Name Timeout -AsInt
$successCount = Get-VstsInput -Name SuccessCount -AsInt

# Create Root URL Array from Multi-line input
$rootUrls = $rootUrls -split '[\r\n]'

# Execute warm up for URLs
foreach ($rootUrl in $rootURLs) {
    .\website-warmup.ps1 -rootUrl $rootUrl -retryCount $retryCount -sleepPeriod $sleepPeriod -ignoreError $ignoreError -suffixes $suffixes -ignoreSslError $ignoreSslError -authMethod $authMethod -user $user -password $password -timeout $timeout -successCount $successCount
}
