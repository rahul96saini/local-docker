#!/bin/sh

while true
do
    MINUTE=$(date +%M)
    MINUTE=$((10#$MINUTE))

    REMAINDER=$((MINUTE % 4))

    if [ "$REMAINDER" -lt 2 ]; then
        MESSAGE="Hello from Rahul"
    else
        MESSAGE="Hello from Aryan"
    fi

    cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>DevOps Daredevils</title>
</head>
<body>
    <h1>$MESSAGE</h1>
</body>
</html>
EOF

    sleep 10
done