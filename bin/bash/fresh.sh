#!/bin/sh

ssh root@socialmaya.com 'service unicorn stop && cd /home/rails/simplr && git pull && service unicorn start'
