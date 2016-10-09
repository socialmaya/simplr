#!/bin/sh

ssh root@45.55.132.214 'service unicorn stop && cd /home/rails/simplr && git pull && service unicorn start'
