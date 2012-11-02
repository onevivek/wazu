#!/bin/sh

while true; do
    date
    ps -ef | egrep 'wazu|ruby' | egrep -v 'grep|tail|vi'
    sleep 4
    clear
done
