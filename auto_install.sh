#!/bin/bash
# Author  : chinatree <chinatree2012@gmail.com>
# Date    : 2014-04-08
# Version : 1.4

# [global]
SCRIPT_PATH=$(cd "$(dirname "$0")"; pwd)
PROJECT_ROOT=$(cd "${SCRIPT_PATH}"; pwd)
RELATIVE_PATH=$(echo "${SCRIPT_PATH}" | sed 's#'$(pwd)'#\##g' | sed 's#^\##.#')
SCRIPT_NAME=$(basename "$0")
USERNAME=$(whoami)
HOME_DIR=$(cd ~; pwd)
COMMON_DIR="${PROJECT_ROOT}/common"
CONFIG_DIR="${PROJECT_ROOT}/etc"
LOGS_DIR="${PROJECT_ROOT}/logs"
TOOLS_DIR="${PROJECT_ROOT}/toolchains"
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
AUTO_CONFIG_SH="${TOOLS_DIR}/auto_config.sh"
COMPILE_FUNC_SH="${COMMON_DIR}/compile_func.sh"
load_file "${COMMON_DIR}/functions.sh"
load_file "${COMMON_DIR}/global.sh"
load_file "${COMPILE_FUNC_SH}"

# trap "get_color \"Received CTRL + C, then stopped!\n\" RED; clean_tmp; exit 2" INT QUIT

#------------------------------------------------ Other Functions ------------------------------------------------#
usage() {
    echo -e "$(get_color "Usage:" CYANBLUE) \
    \n    ${RELATIVE_PATH}/${SCRIPT_NAME} [-a <install|upgrade|uninstall>] [-t <interact|...|lnmp|lamp|...>] [-f <plug-in file>] \
    \n      $(get_fixed_width "-a, --action" -24)do action, default: install \
    \n      $(get_fixed_width "-t, --type" -24)type for action, default: interact \
    \n      $(get_fixed_width "-f, --plug-in-file" -24)plug-in file \
    \n\n`get_color "action:" PEACH` \
    \n    $(get_fixed_width $(get_color "install" GREEN) -40)install software \
    \n    $(get_fixed_width $(get_color "upgrade" GREEN) -40)upgrade software \
    \n    $(get_fixed_width $(get_color "uninstall" GREEN) -40)uninstall software \
    \n\n`get_color "type:" PEACH` \
    \n    $(get_fixed_width $(get_color "interact[_xxx]" GREEN) -40)default value, it will need you input 'Y' or 'y' when install any software \
    \n    $(get_fixed_width $(get_color "interact" GREEN) -40)nginx/apache, mysql, php, php_exts, libs, cache, cache \
    \n    $(get_fixed_width $(get_color "interact_lnmp" GREEN) -40)nginx, mysql, php, cache \
    \n    $(get_fixed_width $(get_color "interact_lamp" GREEN) -40)httpd, mysql, php, cache \
    \n    $(get_fixed_width $(get_color "interact_php_exts" GREEN) -40)APC, xcache, igbinary, memcached, redis, mongo, memcache, uuid, imagick, scws, vpe_cc_reader \
    \n    $(get_fixed_width $(get_color "interact_python_exts" GREEN) -40)setuptools, pip \
    \n    $(get_fixed_width $(get_color "interact_libs" GREEN) -40)libmcrypt, curl, libxml2, jpeg, libpng, libevent, libmemcached, db \
    \n    $(get_fixed_width $(get_color "interact_other" GREEN) -40)tengine, nodejs, java(jdk), python, ImageMagick, scws, mmseg, coreseek, FastDFS, FastDHT \
    \n    $(get_fixed_width $(get_color "lnmp" GREEN) -40)nginx, mysql, libs, php, php_exts, extension \
    \n    $(get_fixed_width $(get_color "lamp" GREEN) -40)httpd, mysql, libs, php, php_exts, extension \
    \n    $(get_fixed_width $(get_color "web" GREEN) -40)nginx php php_exts libs \
    \n    $(get_fixed_width $(get_color "db" GREEN) -40)mysql \
    \n    $(get_fixed_width $(get_color "cache" GREEN) -40)memcached, redis, mongodb, libs \
    \n    $(get_fixed_width $(get_color "php_exts" GREEN) -40)APC, xcache, igbinary, memcached, redis, mongo, memcache, uuid, imagick, scws, vpe_cc_reader \
    \n    $(get_fixed_width $(get_color "python_exts" GREEN) -40)setuptools, pip \
    \n    $(get_fixed_width $(get_color "libs" GREEN) -40)libmcrypt, curl, libxml2, jpeg, libpng, libevent, libmemcached, db \
    \n    $(get_fixed_width $(get_color "other" GREEN) -40)tengine, nodejs, java(jdk), python, ImageMagick, scws, mmseg, coreseek, FastDFS, FastDHT"
    echo ""
    versions
    echo ""
    echo -e "`get_color "Example:" YELLOW` \
    \n    ${RELATIVE_PATH}/${SCRIPT_NAME} -a install -t lnmp \
    \n    ${RELATIVE_PATH}/${SCRIPT_NAME} -a install -t interact \
    \n    ${RELATIVE_PATH}/${SCRIPT_NAME} -a install -t web \
    \n    ${RELATIVE_PATH}/${SCRIPT_NAME} -a install -t custom -f ./common/plug-in.ini"
    exit 2
}

# Parse args use while
parse_arguments_while() {
    while [ $# -gt 0 ]
    do
        case "${1:-NONE}" in
            -a|--act)
                shift
                DO_ACT="$1"
                ;;
            -t|--type)
                shift
                DO_TYPE="$1"
                ;;
            -f|--plug-in-file)
                shift
                PLUG_IN_FILE="$1"
                ;;
            -h|--help)
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
    version_format "nginx" "${nginx_version}"
    version_format "httpd" "${httpd_version}"
    version_format "tengine" "${tengine_version}"
    version_format "mysql" "${mysql_version}"
    version_format "php" "${php_version}"
    version_format "gearmand" "${gearmand_version}"
    version_format "memcached" "${memcached_version}"
    version_format "ImageMagick" "${ImageMagick_version}"
    version_format "redis" "${redis_version}"
    version_format "mongodb" "${mongodb_version}"
    version_format "scws" "${scws_version}"
    version_format "mmseg" "${mmseg_version}"
    version_format "coreseek" "${coreseek_version}"
    version_format "lua" "${lua_version}"
    version_format "node" "${node_version}"
    version_format "jdk" "${jdk_version}"
    version_format "FastDFS" "${FastDFS_version}"
    version_format "FastDHT" "${FastDHT_version}"
    version_format "python" "${python_version}" "Y"

    version_format "[Libs]" " "
    version_format "db" "${libs_db_version}"
    version_format "curl" "${libs_curl_version}"
    version_format "fping" "${libs_fping_version}"
    version_format "freetype" "${libs_freetype_version}"
    version_format "jpeg" "${libs_jpeg_version}"
    version_format "libmcrypt" "${libs_libmcrypt_version}"
    version_format "libmemcached" "${libs_libmemcached_version}"
    version_format "libpng" "${libs_libpng_version}"
    version_format "libxml2" "${libs_libxml2_version}"
    version_format "libevent" "${libs_libevent_version}"
    version_format "mhash" "${libs_mhash_version}"
    version_format "pcre" "${libs_pcre_version}" "Y"

    version_format "[PHP Extensions]" " "
    version_format "APC" "${php_ext_APC_version}"
    version_format "xcache" "${php_ext_xcache_version}"
    version_format "igbinary" "${php_ext_igbinary_version}"
    version_format "memcached" "${php_ext_memcached_version}"
    version_format "redis" "${php_ext_redis_version}"
    version_format "mongo" "${php_ext_mongo_version}"
    version_format "memcache" "${php_ext_memcache_version}"
    version_format "gearman" "${php_ext_gearman_version}"
    version_format "uuid" "${php_ext_uuid_version}"
    version_format "imagick" "${php_ext_imagick_version}"
    version_format "scws" "${php_ext_scws_version}"
    version_format "xdebug" "${php_ext_xdebug_version}"
    version_format "taint" "${php_ext_taint_version}"
    version_format "yaf" "${php_ext_yaf_version}"
    version_format "lua" "${php_ext_lua_version}"
    version_format "intl" "${php_ext_intl_version}"
    version_format "fastdfs_client" "${php_ext_FastDFS_version}" "Y"

    version_format "[Python Extensions]" " "
    version_format "beanstalkc" "${python_ext_beanstalkc_version}"
    version_format "Django" "${python_ext_Django_version}"
    version_format "dnspython" "${python_ext_dnspython_version}"
    version_format "docutils" "${python_ext_docutils_version}"
    version_format "IPy" "${python_ext_IPy_version}"
    version_format "Jinja2" "${python_ext_Jinja2_version}"
    version_format "MarkupSafe" "${python_ext_MarkupSafe_version}"
    version_format "MySQL-python" "${python_ext_MySQL_python_version}"
    version_format "pip" "${python_ext_pip_version}"
    version_format "pssh" "${python_ext_pssh_version}"
    version_format "protobuf" "${python_ext_protobuf_version}"
    version_format "pymongo" "${python_ext_pymongo_version}"
    version_format "pyzmq" "${python_ext_pyzmq_version}"
    version_format "readline" "${python_ext_readline_version}"
    version_format "redis" "${python_ext_redis_version}"
    version_format "salt" "${python_ext_salt_version}"
    version_format "scapy" "${python_ext_scapy_version}"
    version_format "setuptools" "${python_ext_setuptools_version}"
    version_format "shadowsocks" "${python_ext_shadowsocks_version}"
    version_format "tornado" "${python_ext_tornado_version}"
    version_format "XlsxWriter" "${python_ext_XlsxWriter_version}"
}

libs_for_php_func() {
    compile_libs_libmcrypt
    compile_libs_curl
    compile_libs_libiconv
    compile_libs_libxml2 'auto_config'
    compile_libs_jpeg
    compile_libs_libpng
    compile_libs_freetype
    compile_libs_mhash
    compile_libs_zlib
}

libs_func() {
    compile_libs_pcre
    libs_for_php_func
    compile_libs_libevent
    compile_libs_libmemcached
    compile_libs_fping "auto_config"
    #compile_libs_libart_lgpl
    #compile_libs_pango
    compile_libs_db
    compile_libs_libpcap "auto_config"
    compile_libs_libsodium
}

phpexts_func() {
    compile_php_ext_apc
    compile_php_ext_xcache
    compile_php_ext_igbinary
    compile_php_ext_memcached "auto"
    compile_php_ext_memcache
    compile_php_ext_redis
    compile_php_ext_mongo
    compile_php_ext_mongodb
    compile_php_ext_uuid
    compile_php_ext_imagick "auto"
    compile_php_ext_scws "auto"
    compile_php_ext_xdebug
    compile_php_ext_taint
    compile_php_ext_yaf
    #compile_php_ext_intl
    #compile_php_ext_gearman "auto"
    #compile_php_ext_lua "auto"
    compile_php_ext_vpe_cc_reader
}

python_exts_func() {
    compile_python_ext_setuptools
    compile_python_ext_pip
    compile_python_ext_Django
    compile_python_ext_MySQL_python
    compile_python_ext_protobuf
    compile_python_ext_pssh
    compile_python_ext_pymongo
    compile_python_ext_readline
    compile_python_ext_redis
    compile_python_ext_bz2file
    compile_python_ext_PyYAML
    compile_python_ext_MarkupSafe
    compile_python_ext_Jinja2
    compile_python_ext_msgpack_python
    compile_python_ext_pyzmq "auto"
    compile_python_ext_pycrypto
    compile_python_ext_M2Crypto "auto"
    compile_python_ext_msgpack_pure
    compile_python_ext_backports_abc
    compile_python_ext_singledispatch
    compile_python_ext_six
    compile_python_ext_certifi
    compile_python_ext_backports_ssl_match_hostname
    compile_python_ext_tornado
    compile_python_ext_Mako
    compile_python_ext_ioflo
    compile_python_ext_enum34
    compile_python_ext_libnacl
    compile_python_ext_raet
    compile_python_ext_timelib
    compile_python_ext_python_dateutil
    compile_python_ext_salt
    compile_python_ext_websocket_client
    compile_python_ext_requests
    compile_python_ext_docker_py
    compile_python_ext_pyaml
    compile_python_ext_docutils
    compile_python_ext_IPy
    compile_python_ext_dnspython
    compile_python_ext_XlsxWriter
    compile_python_ext_scapy
    compile_python_ext_pyClamd
    compile_python_ext_python_nmap
    compile_python_ext_pexpect
    compile_python_ext_ecdsa
    compile_python_ext_paramiko
    compile_python_ext_shadowsocks
    compile_python_ext_ansible
    compile_python_ext_Quixote
    compile_python_ext_uncompyle
    compile_python_ext_Paginator
    compile_python_ext_pg8000
    compile_python_ext_PyMySQL
    compile_python_ext_SQLAlchemy
    compile_python_ext_Active_SQLAlchemy
}

install_base_packet() {
    local YUM_OS=(centos redhat)
    local APT_GET_OS=(ubuntu)
    local YAST_OS=(susu opensusu)
    local OS_NAME=$(echo "${1:-None}" | tr [:upper:] [:lower:])
    #declare -l OS_NAME="${1:-None}"

    if [ "${OS_NAME}" == "None" ];
    then
        echo `get_color 'Failed to detect the default system, please confirm whether you have installed the following basic package and depend on the package:' PEACH`
        echo '  vim ntp gcc gcc-c++ make automake autoconf rsync wget man lsof'
        echo '  openssl openssl-devel telnet traceroute bind-utils openssh-clients'
        echo '  parted iptables lvm2 curl strace ncurses-devel flex bison libuuid-devel libtool'
        prompt "Continue install(default. Y)?"
        if [ $? -eq 0 ];
        then
            return 0
        else
            exit 1
        fi
    else
        # YUM
        for os_str in "${YUM_OS[@]}";
        do
            if [ "${os_str}" == "${OS_NAME}" ];
            then
                local module="YUM"
                local logfile="${install_log_dir}/${module}.log"
                echo -n "${module} installed the following basic package ... "
                yum -y install vim ntp gcc gcc-c++ make automake autoconf rsync wget man lsof openssl openssl-devel telnet traceroute bind-utils openssh-clients parted iptables lvm2 curl strace patch unzip > "${logfile}" 2>&1
                get_exit_code $? 1
                echo -n "${module} install depend on the package ... "
                yum -y install ncurses-devel flex bison libuuid-devel libtool expat-devel >> "${logfile}" 2>&1
                get_exit_code $? 1

                return 0
            fi
        done

        # APT-GET
        for os_str in "${APT_GET_OS[@]}";
        do
            if [ "${os_str}" == "${OS_NAME}" ];
            then
                local module="APT-GET"
                local logfile="${install_log_dir}/${module}.log"
                echo -n "Aptitude update ... "
                aptitude update > "${logfile}" 2>&1
                get_exit_code '0' 1
                echo -n "${module} installed the following basic package ... "
                apt-get install vim ntp gcc g++ make autoconf rsync wget man-db lsof openssl telnet traceroute parted iptables lvm2 curl strace -y  >> "${logfile}" 2>&1
                get_exit_code $? 1
                echo -n "${module} install depend on the package ... "
                apt-get install libssl-dev libncurses-dev libcurl4-openssl-dev uuid-dev libtool  libreadline-dev libexpat1-dev -y >> "${logfile}" 2>&1
                get_exit_code $? 1

                return 0
            fi
        done

        # YAST_OS
        for os_str in "${YAST_OS[@]}";
        do
            if [ "${os_str}" == "${OS_NAME}" ];
            then
                echo 'pass'
            fi
        done

        echo `get_color 'Failed to detect the default system, please confirm whether you have installed the following basic package and depend on the package:' PEACH`
        echo '  vim ntp gcc gcc-c++ make automake autoconf rsync wget man lsof'
        echo '  openssl openssl-devel telnet traceroute bind-utils openssh-clients'
        echo '  parted iptables lvm2 curl strace ncurses-devel flex bison libuuid-devel libtool'
        prompt "Continue install(default. Y)?"
        if [ $? -eq 0 ];
        then
            return 0
        else
            exit 1
        fi
    fi
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

    if [ "${IS_INSTALL_BASE}" = "1" ];
    then
        echo -e "\n$(get_color '[BASE]' BOLD)"
        install_base_packet "${OS_NAME}"
    fi
}

switch_do_type() {
    local DO_TYPE="${1:-NONE}"
    test "${DO_TYPE}" == "NONE" && return 1
    # avoid recursive call death cycle
    if test "${LAST_DO_TYPE}" == "${DO_TYPE}"
    then
        return 1
    else
        LAST_DO_TYPE="${DO_TYPE}"
    fi

    case "${DO_TYPE}" in
    interact_base)
        interact_choice "install automake?" 'compile_automake auto_config'
        interact_choice "install autoconf?" 'compile_autoconf auto_config'
        interact_choice "install cmake?" 'compile_cmake auto_config'
        return 0
        ;;
    interact)
        switch_do_type 'interact_base'
        interact_choice "install nginx?" 'compile_nginx auto_config'
        interact_choice "install mysql?" 'compile_mysql auto_config'
        interact_choice "install mariadb?" 'compile_mariadb auto_config'
        switch_do_type 'interact_libs'
        interact_choice "install php?" 'compile_php auto_config'
        interact_choice "install php(for httpd)?" 'compile_php_httpd auto_config'
        switch_do_type 'interact_phpexts'
        switch_do_type 'interact_cache'
        switch_do_type 'interact_other'
        switch_do_type 'interact_python_exts'
        return 0
        ;;
    interact_lamp)
        switch_do_type 'interact_base'
        interact_choice "install httpd?" 'compile_httpd auto_config'
        interact_choice "install mysql?" 'compile_mysql auto_config'
        switch_do_type 'interact_libs'
        interact_choice "install php?" 'compile_php_httpd auto_config'
        switch_do_type 'interact_phpexts'
        return 0
        ;;
    interact_lnmp)
        switch_do_type 'interact_base'
        interact_choice "install nginx?" 'compile_nginx auto_config'
        interact_choice "install mysql?" 'compile_mysql auto_config'
        switch_do_type 'interact_libs'
        interact_choice "install php?" 'compile_php auto_config'
        switch_do_type 'interact_phpexts'
        return 0
        ;;
    interact_libs)
        interact_choice "install pcre(for nginx, swig)?" compile_libs_pcre
        interact_choice "install libmcrypt for php?" compile_libs_libmcrypt
        interact_choice "install curl for php?" compile_libs_curl
        interact_choice "install libiconv for php?" compile_libs_libiconv
        interact_choice "install libxml2 for php?" 'compile_libs_libxml2 auto_config'
        interact_choice "install jpeg for php/ImageMagick?" compile_libs_jpeg
        interact_choice "install libpng for php/ImageMagick?" compile_libs_libpng
        interact_choice "install freetype for php?" compile_libs_freetype
        interact_choice "install mhash for php?" compile_libs_mhash
        interact_choice "install zlib for php?" compile_libs_zlib
        interact_choice "install libevent for memcached?" compile_libs_libevent
        interact_choice "install libmemcached for memcached(php_ext)?" compile_libs_libmemcached
        interact_choice "install fping for zabbix?" 'compile_libs_fping auto_config'
        interact_choice "install db for FastDHT?" compile_libs_db
        interact_choice "install libpcap for nethogs?" 'compile_libs_libpcap auto_config'
        interact_choice "install libsodium for libnacl(python_ext)?" compile_libs_libsodium
        return 0
        ;;
    interact_php_exts)
        interact_choice "install apc extension for php?" compile_php_ext_apc
        interact_choice "install xcache extension for php or memcached?" compile_php_ext_xcache
        interact_choice "install igbinary extension for php or memcached?" compile_php_ext_igbinary
        interact_choice "install memcached extension for php?" 'compile_php_ext_memcached interact'
        interact_choice "install memcache extension for php?" compile_php_ext_memcache
        interact_choice "install redis extension for php?" compile_php_ext_redis
        interact_choice "install mongo extension for php?" compile_php_ext_mongo
        interact_choice "install mongodb extension for php?" compile_php_ext_mongodb
        interact_choice "install uuid extension for php?" compile_php_ext_uuid
        interact_choice "install imagick extension for php?" 'compile_php_ext_imagick interact'
        interact_choice "install scws extension for php?" 'compile_php_ext_scws interact'
        interact_choice "install xdebug extension for php?" compile_php_ext_xdebug
        interact_choice "install taint extension for php?" compile_php_ext_taint
        interact_choice "install yaf extension for php?" compile_php_ext_yaf
        interact_choice "install gearman extension for php?" 'compile_php_ext_gearman interact'
        #interact_choice "install lua extension for php?" 'compile_php_ext_lua auto'
        interact_choice "install vpe_cc_reader extension for php?" compile_php_ext_vpe_cc_reader
        interact_choice "install FastDFS extension for php?" compile_php_ext_FastDFS
        #interact_choice "install intl extension for php?" compile_php_ext_intl
        return 0
        ;;
    interact_python_exts)
        interact_choice "install setuptools extension for python?" compile_python_ext_setuptools
        interact_choice "install pip extension for python?" compile_python_ext_pip
        interact_choice "install Django extension for python?" compile_python_ext_Django
        interact_choice "install MySQL-python extension for python?" compile_python_ext_MySQL_python
        interact_choice "install protobuf extension for python?" compile_python_ext_protobuf
        interact_choice "install pssh extension for python?" compile_python_ext_pssh
        interact_choice "install pymongo extension for python?" compile_python_ext_pymongo
        interact_choice "install redis extension for python?" compile_python_ext_redis
        interact_choice "install readline extension for python?" compile_python_ext_readline
        interact_choice "install bz2file extension for python?" compile_python_ext_bz2file
        interact_choice "install PyYAML extension for python(salt)?" compile_python_ext_PyYAML
        interact_choice "install MarkupSafe extension for python(Jinja2, Mako)?" compile_python_ext_MarkupSafe
        interact_choice "install Jinja2 extension for python(salt)?" compile_python_ext_Jinja2
        interact_choice "install msgpack-python extension for python?" compile_python_ext_msgpack_python
        interact_choice "install pyzmq extension for python(salt)?" 'compile_python_ext_pyzmq interact'
        interact_choice "install pycrypto extension for python(paramiko,salt)?" compile_python_ext_pycrypto
        interact_choice "install M2Crypto extension for python(salt)?" 'compile_python_ext_M2Crypto interact'
        interact_choice "install msgpack-pure extension for python(salt)?" compile_python_ext_msgpack_pure
        interact_choice "install six extension for python(raet, docker-py, Paginator, Active-SQLAlchemy, tornado)?" compile_python_ext_six
        interact_choice "install backports_abc extension for python(tornado)?" compile_python_ext_backports_abc
        interact_choice "install singledispatch extension for python(tornado)?" compile_python_ext_singledispatch
        interact_choice "install certifi extension for python(tornado)?" compile_python_ext_certifi
        interact_choice "install backports.ssl_match_hostname extension for python(tornado)?" compile_python_ext_backports_ssl_match_hostname
        interact_choice "install tornado extension for python(salt)?" compile_python_ext_tornado
        interact_choice "install Mako extension for python(salt)?" compile_python_ext_Mako
        interact_choice "install ioflo extension for python(salt, raet)?" compile_python_ext_ioflo
        interact_choice "install enum34 extension for python(raet)?" compile_python_ext_enum34
        interact_choice "install libnacl extension for python(salt, raet)?" compile_python_ext_libnacl
        interact_choice "install raet extension for python(salt)?" compile_python_ext_raet
        interact_choice "install timelib extension for python(salt)?" compile_python_ext_timelib
        interact_choice "install python-dateutil extension for python(salt)?" compile_python_ext_python_dateutil
        interact_choice "install salt extension for python?" compile_python_ext_salt
        interact_choice "install websocket_client extension for python(docker-py)?" compile_python_ext_websocket_client
        interact_choice "install requests extension for python(docker-py)?" compile_python_ext_requests
        interact_choice "install docker-py extension for python?" compile_python_ext_docker_py
        interact_choice "install pyaml extension for python?" compile_python_ext_pyaml
        interact_choice "install docutils extension for python?" compile_python_ext_docutils
        interact_choice "install IPy extension for python?" compile_python_ext_IPy
        interact_choice "install dnspython extension for python?" compile_python_ext_dnspython
        interact_choice "install XlsxWriter extension for python?" compile_python_ext_XlsxWriter
        interact_choice "install scapy extension for python?" compile_python_ext_scapy
        interact_choice "install pyClamd extension for python?" compile_python_ext_pyClamd
        interact_choice "install python-nmap extension for python?" compile_python_ext_python_nmap
        interact_choice "install pexpect extension for python?" compile_python_ext_pexpect
        interact_choice "install ecdsa extension for python(paramiko)?" compile_python_ext_ecdsa
        interact_choice "install paramiko extension for python?" compile_python_ext_paramiko
        interact_choice "install shadowsocks extension for python?" compile_python_ext_shadowsocks
        interact_choice "install ansible extension for python?" compile_python_ext_ansible
        interact_choice "install Quixote extension for python?" compile_python_ext_Quixote
        interact_choice "install uncompyle extension for python?" compile_python_ext_uncompyle
        interact_choice "install Paginator extension for python(Active-SQLAlchemy)?" compile_python_ext_Paginator
        interact_choice "install pg8000 extension for python(Active-SQLAlchemy)?" compile_python_ext_pg8000
        interact_choice "install PyMySQL extension for python(Active-SQLAlchemy)?" compile_python_ext_PyMySQL
        interact_choice "install SQLAlchemy extension for python(Active-SQLAlchemy)?" compile_python_ext_SQLAlchemy
        interact_choice "install Active-SQLAlchemy extension for python?" compile_python_ext_Active_SQLAlchemy
        return 0
        ;;
    interact_cache)
        interact_choice "install memcached?" 'compile_memcached NULL auto_config'
        interact_choice "install redis?" 'compile_redis auto_config'
        interact_choice "install mongodb?" 'compile_mongodb auto_config'
        return 0
        ;;
    interact_hadoop)
        interact_choice "install hadoop?" 'compile_hadoop auto_config'
        interact_choice "install hbase?" 'compile_apache_hbase auto_config'
        interact_choice "install zookeeper?" 'compile_apache_zookeeper auto_config'
        interact_choice "install maven?" 'compile_apache_maven auto_config'
        interact_choice "install ant?" 'compile_apache_ant auto_config'
        return 0
        ;;
    interact_tools)
        interact_choice "install nethogs?" 'compile_tools_nethogs auto_config'
        return 0
        ;;
    interact_salt)
        interact_choice "install salt extension for python?" compile_python_ext_salt
        return 0
        ;;
    interact_ansible)
        interact_choice "install ansible extension for python?" compile_python_ext_ansible
        return 0
        ;;
    interact_web_platform)
        interact_choice "install nginx?" 'compile_nginx auto_config'
        interact_choice "install openresty?" 'compile_openresty auto_config'
        interact_choice "install luarocks?" 'compile_luarocks auto_config'
        interact_choice "install kong?" 'compile_kong auto_config'
        return 0
        ;;
    interact_other)
        interact_choice "install tengine?" 'compile_tengine auto_config'
        interact_choice "install python?" 'compile_python auto_config'
        interact_choice "install nodejs?" 'compile_node auto_config'
        interact_choice "install java(jdk)?" 'compile_jdk auto_config'
        interact_choice "install uuid?" 'compile_uuid auto_config'
        #interact_choice "install lua?" 'compile_lua auto_config'
        interact_choice "install gearmand?" 'compile_gearmand'
        interact_choice "install ImageMagick for imagick(php_ext)?" 'compile_ImageMagick auto_config'
        interact_choice "install scws for scws(php_ext)?" 'compile_scws auto_config'
        interact_choice "install mmseg for coreseek?" 'compile_mmseg auto_config'
        interact_choice "install coreseek?" 'compile_coreseek auto_config'
        interact_choice "install swig(python_ext:M2Crypto)?" 'compile_swig auto auto_config'
        interact_choice "install zeromq()?" 'compile_zeromq auto_config'
        interact_choice "install FastDFS?" 'compile_FastDFS auto_config'
        interact_choice "install FastDHT?" 'compile_FastDHT NULL auto_config'
        return 0
        ;;
    base)
        compile_automake auto_config
        compile_autoconf auto_config
        compile_cmake auto_config
        ;;
    lnmp)
        switch_do_type 'base'
        compile_nginx "auto_config"
        compile_mysql "auto_config"
        libs_for_php_func
        compile_php "auto_config"
        phpexts_func
        return 0
        ;;
    lamp)
        switch_do_type 'base'
        compile_httpd "auto_config"
        compile_mysql "auto_config"
        libs_for_php_func
        compile_php_httpd "auto_config"
        phpexts_func
        return 0
        ;;
    web)
        compile_nginx "auto_config"
        libs_for_php_func
        compile_php "auto_config"
        phpexts_func
        return 0
        ;;
    db)
        compile_mysql "auto_config"
        return 0
        ;;
    cache)
        compile_memcached "auto" "auto_config"
        compile_beanstalkd
        compile_redis "auto_config"
        compile_mongodb "auto_config"
        ;;
    libs)
        libs_func
        return 0
        ;;
    php_exts)
        phpexts_func
        return 0
        ;;
    python_exts)
        python_exts_func
        return 0
        ;;
    monitor)
        compile_zabbix
        return 0
        ;;
    other)
        #compile_tengine "auto_config"
        #compile_node "auto_config"
        #compile_jdk "auto_config"
        #compile_uuid "auto_config"
        #compile_ImageMagick "auto_config"
        #compile_scws "auto_config"
        #compile_mmseg "auto_config"
        #compile_coreseek "auto_config"
        #compile_modsecurity "auto_config"
        #compile_zeromq "auto_config"
        #compile_FastDFS "auto_config"
        #compile_FastDHT "auto" "auto_config"
        #compile_tools_nethogs "auto_config"

        ## For beta
        #compile_libs_cairo
        #compile_rrdtool
        #compile_nagios
        #compile_varnish
        #compile_apache_tomcat "auto_config"

        compile_libs_openssl
        #compile_python_ext_ipython

        ## Test Failed
        #compile_rabbitmq
        #compile_libs_libffi
        #compile_python_ext_cryptography
        #compile_python_ext_pyOpenSSL
        return 0
        ;;
    feature)

        return 0
        ;;
    custom)
        if test -f "${PLUG_IN_FILE}"
        then
            . "${PLUG_IN_FILE}"
            return 0
        else
            return 1
        fi
        ;;
    esac
    return 1
}
#------------------------------------------------ Global Functions ------------------------------------------------#


cd "${PROJECT_ROOT}"
PATH="/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin"
export PATH
DO_ACT='install'
# do action
DO_TYPE=''
# last do action
LAST_DO_TYPE=''
# specific plug-in file
PLUG_IN_FILE=''
parse_arguments_while $@
test "${USERNAME}" != "root" && echo "This script must be run by `get_color "root" PEACH`!" && exit 1
init_env
init_sysinfo

echo -e "\n$(get_color '[COMPILE]' BOLD)"
switch_do_type "${DO_TYPE}"
test $? -eq 1 && usage
cd "${PROJECT_ROOT}"
${AUTO_CONFIG_SH} -t kernel_argv
clean_tmp

exit
