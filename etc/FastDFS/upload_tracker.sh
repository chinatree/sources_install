#!/bin/bash

num="${1:-512}"
i=0
while [ "${i}" -lt "${num}" ] 
do
    fdfs_upload_file /usr/local/services/FastDFS/etc/client.conf /usr/local/services/FastDFS/etc/anti-steal.jpg
    echo 'Upload file status: '$?
    i=$((${i} + 1))
    #sleep 1s
done
