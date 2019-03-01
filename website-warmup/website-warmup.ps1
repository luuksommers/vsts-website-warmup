param(
    [Parameter(Mandatory=$True)]
    [string]$rootUrl,

    [Parameter()]
    [uint16]$retryCount = 10,

    [Parameter()]
    [uint16]$sleepPeriod = 1,

    [Parameter()]
    [boolean]$ignoreError = $false,

    [Parameter()]
    [boolean]$ignoreSslError = $false,

    [Parameter()]
    [string]$suffixes = "/",

    [Parameter()]
    [string]$authMethod,

    [Parameter()]
    [string]$user = $null,

    [Parameter()]
    [string]$password = $null
)

Write-Debug "RootUrl= $rootUrl"
Write-Debug "RetryCount= $retryCount"
Write-Debug "SleepPeriod= $sleepPeriod"
Write-Debug "IgnoreError= $ignoreError"
Write-Debug "Suffixes= $suffixes"
Write-Debug "Auth Method= $authMethod"
if(-not [string]::IsNullOrEmpty($user)){
    Write-Debug "User= $user"
}

# ----------------------------------- IGNORE SSL -----------------------------------
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@

if ($ignoreSslError)
{
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}
$Headers = @{}
switch ($authMethod) {
    "basic" {
        if(-not [string]::IsNullOrEmpty($user)){

            $pair = "$($user):$($password)"
            
            $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
            
            $basicAuthValue = "Basic $encodedCreds"
            
            $Headers = @{
                Authorization = $basicAuthValue
            }
        }
      }
    "cred" {
        if(-not [string]::IsNullOrEmpty($user)){

            $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential($user, $secpasswd)
        }
$Headers = @{}
if(-not [string]::IsNullOrEmpty($basicAuthUser)){
    $pair = "$($basicAuthUser):$($basicAuthPassword)"
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
    $basicAuthValue = "Basic $encodedCreds"
    $Headers = @{
        Authorization = $basicAuthValue
    }
    Default {}
}

if(-not $suffixes) {
    $suffixes = "/"
}

# Loop over the suffixes
($suffixes -split '[\r\n]') | ForEach-Object{
    if($_.StartsWith("/","CurrentCultureIgnoreCase")){
        $url = $rootUrl+$_;
    } else {
        $url = $rootUrl+"/" + $_;
    }

    $siteIsAlive = $false;
    $time =  Measure-Command {
        for($tryIndex=1; $tryIndex -le $retryCount; $tryIndex++){  
            try{
                Write-Host "Invoke-WebRequest $url, try $tryIndex / $retryCount"
                if ($authMethod -eq "cred") {
                    Invoke-WebRequest $url -UseBasicParsing -Credential $credential -TimeoutSec 600
                    $siteIsAlive = $true;
                } else {
                    Invoke-WebRequest $url -UseBasicParsing -Headers $Headers -TimeoutSec 600
                    $siteIsAlive = $true;
                }
                break;
            }
            catch{
                Write-Host "Failed with errorcode $($_.Exception.Response.StatusCode.value__)."
                if($tryIndex -lt $retryCount){
                    Write-Host "Sleep for $sleepPeriod seconds, before try $($tryIndex + 1) / $retryCount"
                    Start-Sleep -s $sleepPeriod
                }
            }
        }
    }

    if($siteIsAlive){
        Write-Host "Site is running in $($time.TotalSeconds) seconds"
    } else {
        Write-Host "Site returned error after $retryCount tries and in $($time.TotalSeconds) seconds"
        if($ignoreError -eq $false) {
            throw $siteIsNotAlive
        }
    }
}
