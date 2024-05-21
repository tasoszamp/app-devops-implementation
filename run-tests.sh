if curl -s -o /dev/null -w "%{http_code}" localhost:8000/goodmorning | grep -q 200; then
    echo "HTTP request successful"
else
    echo "HTTP request failed"
    exit 1
fi