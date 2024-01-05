#!/bin/bash

if [ -z "$1" ]
  then
    echo "No device file provided"
    exit 1
fi

while true
do
  if [ -e "$1" ];
    then
      modprobe "$2"
      break
    else
      sleep 0.1
    fi
done
