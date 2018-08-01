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
load_file "${COMMON_DIR}/functions.sh"
load_file "${COMMON_DIR}/global.sh"

trap "get_color \"Received CTRL + C, then stopped!\n\" RED; clean_tmp; exit 2" INT QUIT

#------------------------------------------------ Global Functions ------------------------------------------------#

# Parse args use while
parse_arguments_while() {
    while [ $# -gt 0 ]
    do
        case "${1:-NONE}" in
            -T|--debug)
                set -x
                ;;
        esac
        shift
    done
}

versions() {
    echo -e "`get_color "Versions:" YELLOW`"

}

init_sysinfo() {
    OS=$(uname -o)
    OS_NAME=$(head -n 1 /etc/issue | awk '{print $1}')
    RELEASE=$(uname -r)
    HOSTNAME=$(uname -n)
    IPADDRS=$(/sbin/ifconfig | grep 'inet addr' | awk '{print $2}' | awk -F ':' '{printf("%s ",$2)}')
    DATE_NOW=$(date '+%Y-%m-%d %H:%M:%S')

    echo $(get_color '[SYSINFO]' BOLD)
    echo "$(get_fixed_width 'OS :' '14') $(get_fixed_width "${OS}" '50' 'Y')"
    echo "$(get_fixed_width 'OS_NAME :' '14') $(get_fixed_width "${OS_NAME}" '50' 'Y')"
    echo "$(get_fixed_width 'RELEASE :' '14') $(get_fixed_width "${RELEASE}" '50' 'Y')"
    echo "$(get_fixed_width 'HOSTNAME :' '14') $(get_fixed_width "${HOSTNAME}" '50' 'Y')"
    echo "$(get_fixed_width 'IP ADDRS :' '14') $(get_fixed_width "${IPADDRS}" '50' 'Y')"
    echo "$(get_fixed_width 'DATE :' '14') $(get_fixed_width "${DATE_NOW}" '50' 'Y')"
    echo "$(get_fixed_width 'PIDS :' '14') $(get_fixed_width "${PROC_PID}" '50' 'Y')"
}

chk_network() {
    local domain='baidu.com'
    echo -n 'Check network status .. '
    ping -c 1 ${domain} -W 1 > /dev/null 2>&1
    test $? -eq 0 && get_exit_code 0 && return 0
    echo "`get_color "The network impassability, please check it and try again!" PEACH`" && exit 1
}

do_download() {
    echo 'Pass'
}

do_main() {
    local file="${1}"
    local taxonomy module url version save_relative_path save_path
    
    while read line
    do
        test "${line:0:1}" == '#' && continue
        taxonomy=$(echo "${line}" | awk -F '|' '{print $1}')
        module=$(echo "${line}" | awk -F '|' '{print $2}')
        url=$(echo "${line}" | awk -F '|' '{print $3}')
        version=$(echo "${line}" | awk -F '|' '{print $4}')
        save_relative_path=$(echo "${line}" | awk -F '|' '{print $5}')
        save_path="${PROJECT_ROOT}/${save_relative_path}"        
        test -z "${url}" && continue
        test ! -d "${save_path}" && mkdir -p "${save_path}"
        cd "${save_path}"
        echo -n "Downloading $(get_color "${taxonomy}" BOLD) $(get_color "${module}-${version}" CYANBLUE) to $(get_color "${save_path}/${url##*/}" UNDERLINE) ... "
        wget -O "${url##*/}" --no-check-certificate "${url}" > /dev/null 2>&1
        get_exit_code $? '0'
    done < "${file}"
}
#------------------------------------------------ Global Functions ------------------------------------------------#

cd "${PROJECT_ROOT}"
DO_TYPE=''
parse_arguments_while $@
test "${USERNAME}" == "root" && echo "You can not execute the script as the `get_color "root" PEACH` user!" && exit 1
test ! -f "${download_list_file}" && echo "The download list file `get_color "${download_list_file}" PEACH` not exists, please check it and try again!" && exit 1

mkdir -p "${install_log_dir}"
init_sysinfo
echo -e "\n$(get_color '[DOWNLOAD]' BOLD)"
chk_network
do_main "${download_list_file}"


exit
