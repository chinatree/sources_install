#!/bin/bash
# Author  : chinatree <chinatree2012@gmail.com>
# Date    : 2014-04-08
# Version : 1.4

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
        echo "The file ${file} not exists, please check it and try again!"
        if [ "${is_exit:-1}" -eq 1 ]; then
            exit 1
        fi
    else
        . "${file}"
    fi
}

load_file "${CONFIG_DIR}"/config.ini

# Auto Install Dependence Script
CONFIGURATION_FUNC_SH="${COMMON_DIR}/configuration_func.sh"
load_file "${COMMON_DIR}/functions.sh"
load_file "${COMMON_DIR}/global.sh"
load_file "${CONFIGURATION_FUNC_SH}"

trap "get_color \"Received CTRL + C, then stopped!\n\" RED; clean_tmp; exit 2" INT QUIT

#------------------------------------------------ Global Functions ------------------------------------------------#

usage() {
    echo -e "`get_color "Usage:" CYANBLUE` \
    \n    ${RELATIVE_PATH}/${SCRIPT_NAME} [-t <interact|...|all|nginx|...>] [-H|--help] [-D|--debug] \
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
            -H|--help)
                usage
                ;;      
            -D|--debug)
                set -x
                ;;
        esac
        shift
    done
}

versions() {
    echo -e "`get_color "Versions:" YELLOW`"
    version_format "[Main]" " "
    version_format "cmake" "${cmake_version}"
    version_format "beanstalkd" "${beanstalkd_version}"
    version_format "nginx" "${nginx_version}"
    version_format "tengine" "${tengine_version}"
    version_format "mysql" "${mysql_version}"
    version_format "mariadb" "${mariadb_version}"
    version_format "php" "${php_version}"
    version_format "gearmand" "${gearmand_version}"
    version_format "memcached" "${memcached_version}"
    version_format "ImageMagick" "${ImageMagick_version}"
    version_format "redis" "${redis_version}"
    version_format "mongo" "${mongo_version}"
    version_format "uuid" "${uuid_version}"
    version_format "scws" "${scws_version}"
    version_format "node" "${node_version}"
    version_format "FastDFS" "${FastDFS_version}"
    version_format "FastDHT" "${FastDHT_version}"
    version_format "python" "${python_version}"
    version_format "hadoop" "${hadoop_version}" "Y"

    version_format "[Libs]" " "
    version_format "libxml2" "${libs_libxml2_version}"
    version_format "db" "${libs_db_version}" 'Y'
    
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
        interact_choice "configuration cmake?" configuration_cmake
        interact_choice "configuration beanstalkd?" configuration_beanstalkd
        
        interact_choice "configuration nginx?" configuration_nginx
        interact_choice "configuration mysql?" configuration_mysql
        interact_choice "configuration library libxml2?" configuration_libs_libxml2
        interact_choice "configuration ImageMagick?" configuration_ImageMagick
        interact_choice "configuration node?" configuration_node
        interact_choice "configuration memcached?" configuration_memcached
        interact_choice "configuration mongodb?" configuration_mongodb
        interact_choice "configuration php?" configuration_php
        interact_choice "configuration Python?" configuration_python
        interact_choice "configuration redis?" configuration_redis
        interact_choice "configuration uuid?" configuration_uuid

        interact_choice "configuration scws?" configuration_scws
        interact_choice "configuration mmseg?" configuration_mmseg
        interact_choice "configuration coreseek?" configuration_coreseek

        interact_choice "configuration FastDFS?" configuration_FastDFS
        interact_choice "configuration library (berkeley-db)db?" configuration_libs_db
        interact_choice "configuration FastDHT?" configuration_FastDHT

        interact_choice "modify kernel argv?" optimize_kernel_argv
        ;;
    automake)
        configuration_automake
        ;;
    autoconf)
        configuration_autoconf
        ;;
    cmake)
        configuration_cmake
        ;;
    beanstalkd)
        configuration_beanstalkd
        ;;
    nginx)
        configuration_nginx
        ;;
    tengine)
        configuration_tengine
        ;;
    mysql)
        configuration_mysql
        ;;
    mariadb)
        configuration_mariadb
        ;;
    php)
        configuration_php
        ;;
    node)
        configuration_node
        ;;
    Python|python)
        configuration_python
        ;;
    java|jdk)
        configuration_jdk
        ;;
    hadoop)
        configuration_hadoop
        ;;
    hbase)
        configuration_hbase
        ;;
    zookeeper)
        configuration_zookeeper
        ;;
    tomcat)
        configuration_apache_tomcat
        ;;
    maven)
        configuration_apache_maven
        ;;
    ant)
        configuration_apache_ant
        ;;
    memcached)
        configuration_memcached
        ;;
    redis)
        configuration_redis
        ;;
    uuid)
        configuration_uuid
        ;;
    mongodb)
        configuration_mongodb
        ;;
    libs_libxml2)
        configuration_libs_libxml2
        ;;
    libs_db)
        configuration_libs_db
        ;;
    libs_fping)
        configuration_libs_fping
        ;;
    libs_libpcap)
        configuration_libs_libpcap
        ;;
    libs_libsodium)
        configuration_libs_libsodium
        ;;
    phpext_FastDFS|phpext_fastdfs)
        configuration_php_ext_FastDFS
        ;;
    zeromq)
        configuration_zeromq
        ;;
    swig)
        configuration_swig
        ;;
    scws)
        configuration_scws
        ;;
    mmseg)
        configuration_mmseg
        ;;
    zabbix)
        configuration_zabbix
        ;;
    coreseek)
        configuration_coreseek
        ;;
    ImageMagick)
        configuration_ImageMagick
        ;;
    FastDFS|fastdfs)
        configuration_FastDFS
        ;;
    FastDHT|fastdht)
        configuration_FastDHT
        ;;
    python_ext_pip)
        configuration_python_ext_pip
        ;;
    python_ext_salt)
        configuration_python_ext_salt
        ;;
    tools_nethogs)
        configuration_tools_nethogs
        ;;
    kernel_argv)
        optimize_kernel_argv
        ;;
    all)
        echo 'Pass'
        ;;
    *)
        usage
        ;;
esac

exit
