#!/bin/sh

echo -e "\nFetching latest access log...\n"

ssh root@104.131.182.123 'cp /var/log/nginx/access.log ~/ && chmod 755 ~/access.log'

echo "get access.log" | sftp root@104.131.182.123

echo -e "\nCleaning up...\n"

ssh root@104.131.182.123 'rm ~/access.log'

echo -e "Playing log...\n"

logstalgia -1280x720 ~/access.log
