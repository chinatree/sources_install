#!/bin/bash
# Author  : chinatree <chinatree2012@gmail.com>
# Date    : 2014-04-08
# Version : 1.0

# [global]
SCRIPT_PATH=$(cd "$(dirname "$0")"; pwd)
PROJECT_ROOT=$(cd "${SCRIPT_PATH}/../"; pwd)
RELATIVE_PATH=$(echo "${SCRIPT_PATH}" | sed 's#'$(pwd)'#\##g' | sed 's#^\##.#')
SCRIPT_NAME=$(basename "$0")
USERNAME=$(whoami)
HOME_DIR=$(cd ~; pwd)
COMMON_DIR="${PROJECT_ROOT}/common"
CONFIG_DIR="${PROJECT_ROOT}/etc"
LOGS_DIR="${PROJECT_ROOT}/logs"
PARA_NUM="$#"
PROC_PID="$$"

load_file()
{
    local file="$1"
    local is_exit="$2"
    if [ ! -f "${file}" ]; then
        echo "The file "${file}" not exists, please check it and try again!"
        if [ "${is_exit:-1}" -eq 1 ]; then
            exit 1
        fi
    else
        . "${file}"
    fi
}

load_file "${CONFIG_DIR}"/config.ini

# Auto Install Dependence Script
SOFTCHAIN_FUNC_SH="${COMMON_DIR}/softchain_func.sh"
load_file "${COMMON_DIR}/functions.sh"
load_file "${COMMON_DIR}/global.sh"
load_file "${SOFTCHAIN_FUNC_SH}"

trap "get_color \"Received CTRL + C, then stopped!\n\" RED; clean_tmp; exit 2" INT QUIT

#------------------------------------------------ Global Functions ------------------------------------------------#

usage() {
    echo -e "`get_color "Usage:" CYANBLUE` \
    \n    ${RELATIVE_PATH}/${SCRIPT_NAME} [-t <interact|...|all|nginx|...>] \
    \n      $(get_fixed_width "-t, --type" -24)type for action \
    \n\n`get_color "Tips:" PEACH` \
    \n    `get_color "interact" GREEN` : it will need you input 'Y' or 'y' when install any software"
    echo ""
    versions
    exit 2
}

# Parse args use while
parse_arguments_while() {
    while [ $# -gt 0 ]
    do
        case "${1:-NONE}" in
            -t|--type)
                shift
                DO_TYPE="$1"
                ;;
            -h|--help)
                usage
                ;;      
            -T|--debug)
                set -x
                ;;
        esac
        shift
    done
}

versions() {
    echo -e "`get_color "Versions:" YELLOW`"
    version_format "[Main]" " "
    version_format "nginx" "${nginx_version}"
    version_format "tengine" "${tengine_version}"
    version_format "mysql" "${mysql_version}"
    version_format "php" "${php_version}"
    version_format "gearmand" "${gearmand_version}"
    version_format "memcached" "${memcached_version}"
    version_format "ImageMagick" "${ImageMagick_version}"
    version_format "redis" "${redis_version}"
    version_format "mongo" "${mongo_version}"
    version_format "uuid" "${uuid_version}"
    version_format "scws" "${scws_version}"
    version_format "node" "${node_version}"
    version_format "python" "2.7.3+" "Y"

    version_format "[Libs]" " " 'Y'
    
    version_format "[Python Extensions]" " " 'Y'
}

chk_not_exists_user() {
    local user="${1:-None}"
    local not_exists_line=$(id "${user}" 2>&1 | grep 'No such user' | wc -l)

    if [ "${not_exists_line}" -eq 1 ];
    then
        return 1
    fi
    return 0    
}
#------------------------------------------------ Global Functions ------------------------------------------------#

cd "${PROJECT_ROOT}"
DO_TYPE=''
parse_arguments_while $@
test "${USERNAME}" != "root" && echo "This script must be run by `get_color "root" PEACH`!" && exit 1
init_env

case "${DO_TYPE}" in
interact)
    interact_choice "softchain nginx?" softchain_nginx
    interact_choice "softchain mysql?" softchain_mysql
    interact_choice "softchain libxml2?" softchain_libxml2
    interact_choice "softchain php?" softchain_php
    interact_choice "softchain ImageMagick?" softchain_ImageMagick
    interact_choice "softchain memcached?" softchain_memcached
    interact_choice "softchain scws?" softchain_scws
    interact_choice "softchain mmseg?" softchain_mmseg
    interact_choice "softchain coreseek?" softchain_coreseek

    interact_choice "modify kernel argv?" modify_kernel_argv
    ;;
nginx)
    softchain_nginx
    ;;
tengine)
    softchain_tengine
    ;;
mysql)
    softchain_mysql
    ;;
php)
    softchain_php
    ;;
node)
    softchain_node
    ;;
Python|python)
    softchain_python
    ;;
java|jdk)
    softchain_jdk
    ;;
memcached)
    softchain_memcached
    ;;
redis)
    softchain_redis
    ;;
uuid)
    softchain_uuid
    ;;
mongodb)
    softchain_mongodb
    ;;
libxml2)
    softchain_libxml2
    ;;
scws)
    softchain_scws
    ;;
mmseg)
    softchain_mmseg
    ;;
coreseek)
    softchain_coreseek
    ;;
ImageMagick)
    softchain_ImageMagick
    ;;
all)
    echo 'Pass'
    ;;
*)
    usage
    ;;
esac

exit
