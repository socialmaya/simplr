#!/bin/sh

ssh root@anrcho.com 'service unicorn stop && cd /home/rails/simplr && git pull && service unicorn start'
