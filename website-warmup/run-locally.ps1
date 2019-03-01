Write-Verbose "Entering script run-locally.ps1"

<#No Security#>

$rootUrl = "https://google.com"
$retryCount = 2
$sleepPeriod = 1
$ignoreError = $false
$ignoreSslError = $false
$suffixes = "/
/mail
fail"
$authMethod = "none"
$user = ""
$password = ""



.\website-warmup.ps1  -rootUrl $rootUrl -retryCount $retryCount -sleepPeriod $sleepPeriod -ignoreError $ignoreError -suffixes $suffixes -ignoreSslError $ignoreSslError -authMethod $authMethod  -user $user -password $password

<#End No Security#>

<#Basic Sercurity#>

$user = "guest"
$password = "guest"
$rootUrl = "https://jigsaw.w3.org/"
$suffixes = "/HTTP/Basic/"
$authMethod = "basic"

.\website-warmup.ps1 -rootUrl $rootUrl -suffixes $suffixes -authMethod $authMethod -user $user -password $password

$password = "guest1"

#.\website-warmup.ps1 -rootUrl $rootUrl -suffixes $suffixes -authMethod $authMethod -user $user -password $password

<#Credentials#>

$user = "username"
$password = "falsepassword"
$rootUrl = "localhost"
$suffixes = "/"
$authMethod = "cred"

.\website-warmup.ps1 -rootUrl $rootUrl -suffixes $suffixes -authMethod $authMethod -user $user -password $password

$password = "yourpassword"

.\website-warmup.ps1 -rootUrl $rootUrl -suffixes $suffixes -authMethod $authMethod -user $user -password $password

<#End Credentials#>