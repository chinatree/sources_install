#!/bin/bash
# Author  : chinatree <chinatree2012@gmail.com>
# Date    : 2016-01-07
# Version : 1.0

# [global]
SCRIPT_PATH=$(cd "$(dirname "$0")"; pwd)
PROJECT_ROOT=$(cd "${SCRIPT_PATH}/../"; pwd)
RELATIVE_PATH=$(echo "${SCRIPT_PATH}" | sed 's#'$(pwd)'#\##g' | sed 's#^\##.#')
SCRIPT_NAME=$(basename "$0")
USERNAME=$(whoami)
HOME_DIR=$(cd ~; pwd)
COMMON_DIR="${PROJECT_ROOT}/common"
PARA_NUM="$#"
PROC_PID="$$"

if [ ! -f "${COMMON_DIR}/functions.sh" ];
then
    echo "The common function file ${COMMON_DIR}/functions.sh not exists, please check it and try again!"
    exit 1
else
    . "${COMMON_DIR}/functions.sh"
fi

create_compile_func() {
    :
}

create_compile_python_exts_func() {
    local example_file="${COMPILE_EXAMPLE_FUNC_DIR}/python_ext.func"
    local module_name="${1}"
    local module_name_conver="$(echo ${module_name} | tr '-' '_')"
    echo "${module_name}"
    echo "${module_name_conver}"
}


# Parse args use while
parse_arguments_while() {
    while [ $# -gt 0 ]
    do
        case "${1:-NONE}" in
            -t|--type)
                shift
                TYPE="$1"
                ;;
            -n|--name)
                shift
                NAME="$1"
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

# Main
TYPE=""
NAME=""
FUNC_DIR="${PROJECT_ROOT}/func"
COMPILE_EXAMPLE_FUNC_DIR="${FUNC_DIR}/example/compile"
COMPILE_SERVER_FUNC_DIR="${FUNC_DIR}/compile"
COMPILE_PHP_EXTS_FUNC_DIR="${COMPILE_SERVER_FUNC_DIR}/php_exts"
COMPILE_PYTHON_EXTS_FUNC_DIR="${COMPILE_SERVER_FUNC_DIR}/python_exts"

parse_arguments_while $@

case "${TYPE:-NONE}" in
    python_exts)
        create_compile_python_exts_func "${NAME}"
        ;;
    *)
        :
        ;;
esac

create_compile_func

exit
