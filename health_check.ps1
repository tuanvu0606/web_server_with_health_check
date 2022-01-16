param (    
    # create or destroy
    [string]$server_address = ''
)

Function health_check {
    try {
        $Env:Curl_Results = (Invoke-WebRequest -Uri $server_address -UseBasicParsing | Select-Object -Expand StatusCode)

        # Check for timeout
        if ($Env:Curl_Results -eq "200"){
            Write-Output "Connected"
        } elseif (404){
            Write-Output "Not Found"
        }
        else {
            Write-Output "This is the status code"
            Write-Output $Env:Curl_Results
        }
    } catch [System.Net.WebException] {
        "Error WebException"
    } 
    catch {
        Write-Output "Unknown Error happens"
    }
    
}

health_check