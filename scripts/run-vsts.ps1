Write-Verbose "Entering script run-vsts.ps1"

$rootUrl = Get-VstsInput -Name Url

.\webapp-warmup.ps1  -rootUrl $rootUrl