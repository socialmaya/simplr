#!/bin/sh

echo "\nCopying...\n"

cd ~/Code/GitHub/

rm -rf simplr/*

cp -r ~/Code/rails/simplr/ ~/Code/GitHub/simplr/

cd ~/Code/GitHub/simplr

echo "Committing...\n"

git add -A

git commit -m "$1"

git push

echo "\n"
