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
$timeout = 600

.\website-warmup.ps1 -rootUrl $rootUrl -retryCount $retryCount -sleepPeriod $sleepPeriod -ignoreError $ignoreError -suffixes $suffixes -ignoreSslError $ignoreSslError -authMethod $authMethod  -user $user -password $password -timeout $timeout

<#End No Security#>

<#Basic Sercurity#>

$user = "guest"
$password = "guest"
$rootUrl = "localhost"
$suffixes = "/your/query/"
#Mandentory
$authMethod = "basic"

.\website-warmup.ps1 -rootUrl $rootUrl -suffixes $suffixes -authMethod $authMethod -user $user -password $password

$password = "guest1"

#.\website-warmup.ps1 -rootUrl $rootUrl -suffixes $suffixes -authMethod $authMethod -user $user -password $password

<#End Basic Security#>

<#Credentials#>

$user = "username"
$password = "falsepassword"
$rootUrl = "localhost"
$suffixes = "/"
#Mandentory
$authMethod = "cred"

.\website-warmup.ps1 -rootUrl $rootUrl -suffixes $suffixes -authMethod $authMethod -user $user -password $password

$password = "yourpassword"

.\website-warmup.ps1 -rootUrl $rootUrl -suffixes $suffixes -authMethod $authMethod -user $user -password $password

<#End Credentials#>