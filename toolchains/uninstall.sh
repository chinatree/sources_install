#!/bin/bash
# Author  : chinatree <chinatree2012@gmail.com>
# Date    : 2014-01-28
# Version : 1.0

# [global]
SCRIPT_PATH=$(cd "$(dirname "$0")/../"; pwd)
SCRIPT_NAME=$(basename "$0")
USERNAME=$(whoami)
HOME_DIR=$(cd ~; pwd)
PARA_NUM="$#"

# Define path
path_local_bin="/usr/local/bin"
install_dir_prefix="/usr/local/services"
install_libs_dir_prefix=""${install_dir_prefix}"/libs"

#rm -f ${path_local_bin:-None}/*
rm -rf ${install_dir_prefix:-None}/*
exit
