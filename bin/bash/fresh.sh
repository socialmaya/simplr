#!/bin/sh

ssh root@104.131.182.123 'service unicorn stop && cd /home/rails/simplr && git pull && service unicorn start'
