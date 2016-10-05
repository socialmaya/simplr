#!/bin/sh

ssh root@159.203.168.203 'service unicorn stop && cd /home/rails/simplr && git pull && service unicorn start'
