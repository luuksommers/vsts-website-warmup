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
    [string]$suffixes = "/"
)

Write-Debug "RootUrl= $rootUrl"
Write-Debug "RetryCount= $retryCount"
Write-Debug "SleepPeriod= $sleepPeriod"
Write-Debug "IgnoreError= $ignoreError"
Write-Debug "Suffixes= $suffixes"

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

if(-not $suffixes) {
    $suffixes = "/"
}

($suffixes -split '[\r\n]') | ForEach-Object{
    if($_.StartsWith("/","CurrentCultureIgnoreCase")){
        $url = $rootUrl+$_;
    } else {
        $url = $rootUrl+"/" + $_;
    }

    Write-Host "wget $url"

    $time =  Measure-Command {
        for($tryIndex=0; $tryIndex -le $retryCount; $tryIndex++){  
            try{
                Invoke-WebRequest $url -UseBasicParsing -ErrorAction Stop -ErrorVariable siteIsNotAlive
                break;
            }
            catch{
                Write-Debug "Sleep + repeat"
                Start-Sleep -s $sleepPeriod
            }
        }
    }

    if($siteIsNotAlive){
        if($ignoreError -eq $false) {
            throw $siteIsNotAlive
        } else {
             Write-Host "Site returned error after $retryCount tries and in $($time.TotalSeconds) seconds"
        }
    } else {
        Write-Host "Site is running in $($time.TotalSeconds) seconds"
    }
}




