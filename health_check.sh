
health_check() {

    # Use Curl for health check, and results are based on status code

    HEADERS=`curl -Is --connect-timeout 1 $1`
    CURLSTATUS=$?

    # Check for timeout
    if [ $CURLSTATUS -eq 28 ]
        then
            echo "TIMEOUT"
    else
        # Check HTTP status code
        HTTPSTATUS=`echo $HEADERS | grep HTTP | cut -d' ' -f2`
        if [ $HTTPSTATUS -eq 200 ]; then
            echo "CONNECTED"
        elif [ $HTTPSTATUS -eq 301 ]; then
            echo "MOVED PERMANENTLY"
        elif [ $HTTPSTATUS -eq 404 ]; then 
            echo "NOT FOUND"
        elif [ $HTTPSTATUS -le 399 ]; then
            echo "ERROR CODE"
            echo $HTTPSTATUS
        else
            echo "RECEIVE THIS CODE"
            echo $HTTPSTATUS
        fi
    fi
}
