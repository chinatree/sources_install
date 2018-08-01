#!/bin/bash

file="${1:-NONE}"
if test "${file}" != 'NONE'
then
    fdfs_file_info /usr/local/services/FastDFS/etc/client.conf "${file}"
else
    echo 'the <file_id> invalid!'
fi
