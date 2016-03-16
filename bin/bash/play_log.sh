#!/bin/sh

echo "\nFetching latest access log...\n"

ssh root@104.131.182.123 'cp /var/log/nginx/access.log ~/ && chmod 755 ~/access.log'

echo "get access.log" | sftp root@104.131.182.123

echo "\nCleaning up...\n"

ssh root@104.131.182.123 'rm ~/access.log'

echo "Playing log...\n"

logstalgia -1280x720 ~/access.log
