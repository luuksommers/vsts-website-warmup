Write-Verbose "Entering script run-locally.ps1"

$authMethod = "none" # None, Basic, Cred

# Variables for all Security Methods 
# Mandatory
$rootUrl = "https://google.com" 

# Optional
$suffixes = "/
/mail
fail" 
$retryCount = 2
$sleepPeriod = 1
$ignoreError = $false
$ignoreSslError = $false
$timeout = 600

# Variables for Basic or Cred Security
$user = "guest"
$password = "guest"

# Run warm up locally with all switches
.\website-warmup.ps1 -rootUrl $rootUrl -retryCount $retryCount -sleepPeriod $sleepPeriod -ignoreError $ignoreError -suffixes $suffixes -ignoreSslError $ignoreSslError -authMethod $authMethod -user $user -password $password -timeout $timeout

# Example command with limited switches
#.\website-warmup.ps1 -rootUrl $rootUrl -suffixes $suffixes -authMethod $authMethod -user $user -password $password
