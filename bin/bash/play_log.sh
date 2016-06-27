#!/bin/sh

echo -e "\nFetching latest access log...\n"

ssh root@socialmaya.com 'cp /var/log/nginx/access.log ~/ && chmod 755 ~/access.log'

echo "get access.log" | sftp root@socialmaya.com

echo -e "\nCleaning up...\n"

ssh root@socialmaya.com 'rm ~/access.log'

echo -e "Playing log...\n"

logstalgia -1280x720 ~/access.log
