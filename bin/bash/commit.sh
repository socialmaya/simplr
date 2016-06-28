#!/bin/sh

echo "Committing...\n"

git add -A

git commit -m "$1"

git push

echo "\n"
