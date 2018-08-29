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
    [SecureString]$basicAuthPassword = $null
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

# http://blog.majcica.com/2015/11/17/powershell-tips-and-tricks-decoding-securestring/
function Get-PlainText()
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.Security.SecureString]$SecureString
	)
	BEGIN { }
	PROCESS
	{
		$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString);
 
		try
		{
			return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr);
		}
		finally
		{
			[Runtime.InteropServices.Marshal]::FreeBSTR($bstr);
		}
	}
	END { }
}

$Headers = @{}
if(-not [string]::IsNullOrEmpty($basicAuthUser)){

    $pw = Get-PlainText $basicAuthPassword
    $pair = "$($basicAuthUser):$($pw)"
$pair
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

    Write-Host "wget $url"

    $time =  Measure-Command {
        for($tryIndex=0; $tryIndex -le $retryCount; $tryIndex++){  
            try{
                Invoke-WebRequest $SolrUrl -UseBasicParsing -ErrorAction Stop
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
