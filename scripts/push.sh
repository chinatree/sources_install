#!/bin/sh
/usr/bin/rsync -vzrtopg --delete  /data0/htdocs/www/ 192.168.1.1::www/
