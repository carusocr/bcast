#!/bin/bash
for i in $(curl -s http://gdata.youtube.com/feeds/api/users/"$1"/uploads | grep -Eo "watch\?v=[^[:space:]\"\'\\]{11}" | uniq); do echo $i;done
