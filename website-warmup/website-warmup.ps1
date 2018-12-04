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
    [string]$basicAuthUser = $null,

    [Parameter()]
    [string]$basicAuthPassword = $null
)

Write-Debug "RootUrl= $rootUrl"
Write-Debug "RetryCount= $retryCount"
Write-Debug "SleepPeriod= $sleepPeriod"
Write-Debug "IgnoreError= $ignoreError"
Write-Debug "Suffixes= $suffixes"
Write-Debug "BasicAuthUser= $basicAuthUser"

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

# ----------------------------------- BASIC AUTH -----------------------------------

$Headers = @{}
if(-not [string]::IsNullOrEmpty($basicAuthUser)){

    $pair = "$($basicAuthUser):$($basicAuthPassword)"
    
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
    
    $basicAuthValue = "Basic $encodedCreds"
    
    $Headers = @{
        Authorization = $basicAuthValue
    }
}

if(-not $suffixes) {
    $suffixes = "/"
}

($suffixes -split '[\r\n]') | ForEach-Object{
    if($_.StartsWith("/","CurrentCultureIgnoreCase")){
        $url = $rootUrl+$_;
    } else {
        $url = $rootUrl+"/" + $_;
    }

    $time =  Measure-Command {
        for($tryIndex=1; $tryIndex -le $retryCount; $tryIndex++){  
            try{
                Write-Host "Invoke-WebRequest $url"
                Invoke-WebRequest $url -UseBasicParsing -ErrorAction silentlycontinue -ErrorVariable siteIsNotAlive -Headers $Headers
                break;
            }
            catch{
                Write-Host "Sleep for $sleepPeriod x seconds"
                Start-Sleep -s $sleepPeriod
                Write-Host "Repeat $tryIndex / $retryCount"
            }
        }
    }

    if($siteIsNotAlive){
        Write-Host "Site returned error after $retryCount tries and in $($time.TotalSeconds) seconds"
        if($ignoreError -eq $false) {
            throw $siteIsNotAlive
        }
    } else {
        Write-Host "Site is running in $($time.TotalSeconds) seconds"
    }
}
