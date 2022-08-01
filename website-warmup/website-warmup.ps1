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
    [string]$password = $null,

    [Parameter()]
    [uint16]$timeout = 600,

    [Parameter()]
    [uint16]$successCount = 1
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
# ----------------------------------- AUTH METHODS ---------------------------------
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
    }
    Default {
        $Headers = @{}
    }
}

if(-not $suffixes) {
    $suffixes = "/"
}

# Loop over the suffixes
($suffixes -split '[\r\n]') | ForEach-Object{
    if($_.StartsWith("/","CurrentCultureIgnoreCase")){
        $url = $rootUrl+$_;
    } elseif($_.StartsWith(":","CurrentCultureIgnoreCase")){
        $url = $rootUrl+$_;
    } else {
        $url = $rootUrl+"/" + $_;
    }

    $siteIsAliveCount = 0;
    $time =  Measure-Command {
        for($tryIndex=1; $tryIndex -le $retryCount; $tryIndex++){  
            try{
                Write-Host "Invoke-WebRequest $url, try $tryIndex / $retryCount"
                if ($authMethod -eq "cred") {
                    Invoke-WebRequest $url -UseBasicParsing -Credential $credential -TimeoutSec $timeout
                } else {
                    Invoke-WebRequest $url -UseBasicParsing -Headers $Headers -TimeoutSec $timeout
                }
                $siteIsAliveCount++;
                if($siteIsAliveCount -ge $successCount){
                    break;
                } else {
                    Write-Host "Site is up, check $($siteIsAliveCount) / $($successCount), will do another check."
                    Start-Sleep -s $sleepPeriod
                }
            }
            catch [System.Net.WebException] {
                If ($_.Exception.Message) {
                    Write-Warning $_.Exception.Message
                }
                if($tryIndex -lt $retryCount){
                    Write-Host "Sleep for $sleepPeriod seconds, before try $($tryIndex + 1) / $retryCount"
                    Start-Sleep -s $sleepPeriod
                }
                $siteIsAliveCount--
            }
            catch {
                throw $_
            }
        }
    }

    if($siteIsAliveCount -ge $successCount){
        Write-Host "Site is running in $($time.TotalSeconds) seconds"
    } else {
        Write-Host "Site returned error after $retryCount tries and in $($time.TotalSeconds) seconds!"
        if($ignoreError -eq $false) {
            throw "Error warm-up $url"
        }
    }
}
