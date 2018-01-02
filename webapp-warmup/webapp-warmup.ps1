param(
    [Parameter(Mandatory=$True)]
    [string]$rootUrl
)

Write-Debug "RootUrl= $rootUrl"
#Make sure that website is alive
for($tryIndex=0; $tryIndex -le 10; $tryIndex++){  
    try{
        $time =  Measure-Command{Invoke-WebRequest $rootUrl -UseBasicParsing -ErrorAction Stop -ErrorVariable siteIsNotAlive}
        Write-Host "Site is running"
        Write-Host "wget $rootUrl in $($time.TotalSeconds)"
        break;
    }
    catch{
        Write-Debug "Sleep + repeat"
        Start-Sleep -s 1
    }
}

if($siteIsNotAlive){
    throw $siteIsNotAlive
}

#url suffixes
#$suffixes = @("/", "/url_1", "url_2")
#
#$suffixes | ForEach-Object{
#    $url = $rootUrl+$_;
#    $time = Measure-Command{Invoke-WebRequest $url -UseBasicParsing}
#    Write-Host "wget $url in $($time.TotalSeconds)"
#}