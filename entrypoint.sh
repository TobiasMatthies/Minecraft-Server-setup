#!/bin/sh
echo "eula=true" > eula.txt
exec java -Xms2G -Xmx4G -jar /app/server.jar --nogui
