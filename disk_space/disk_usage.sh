#!/bin/bash
#Monitor Linux disk space
ALERT=5 # alert level 
df -H | grep -vE '^Filesystem|tmpfs|cdrom|loop*' | awk '{ print $2" " $6 " " $5 }' | while read -r output;
do
  #echo "$output"
  usep=$(echo "$output" | awk '{ print $3}' | cut -d'%' -f1 )
  partition=$(echo "$output" | awk '{ print $2 }' )
  if [ $usep -ge $ALERT ]; then
    echo "Running out of space \"$partition ($usep%)\" on.. $(hostname) as on $(date)" 
    echo "Running out of space \"$partition ($usep%)\" " 
  fi
done
