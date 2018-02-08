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
    [string]$suffixes = "/"
)

Write-Debug "RootUrl= $rootUrl"
Write-Debug "RetryCount= $retryCount"
Write-Debug "SleepPeriod= $sleepPeriod"
Write-Debug "IgnoreError= $ignoreError"
Write-Debug "Suffixes= $suffixes"

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




