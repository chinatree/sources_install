#!/bin/bash
# Author  : chinatree <chinatree2012@gmail.com>
# Date    : 2014-05-06
# Version : 1.1

# [global]
SCRIPT_PATH=$(cd "$(dirname "$0")/../"; pwd)
PROJECT_ROOT=$(cd "${SCRIPT_PATH}"; pwd)
RELATIVE_PATH=$(echo "${SCRIPT_PATH}" | sed 's#'$(pwd)'#\##g' | sed 's#^\##.#')
SCRIPT_NAME=$(basename "$0")
USERNAME=$(whoami)
HOME_DIR=$(cd ~; pwd)
LOGS_DIR="${PROJECT_ROOT}/logs"
TOOLS_DIR="${PROJECT_ROOT}/toolchains"
PARA_NUM="$#"
PROC_PID="$$"

find "${PROJECT_ROOT}" -name "*.sh" | xargs /bin/chmod 755
find "${PROJECT_ROOT}" -name "*.py" -exec /bin/chmod 755 {} \;
chmod 755 "${PROJECT_ROOT}"/scripts/*

# Merge func
${TOOLS_DIR}/merge_global_func.sh
${TOOLS_DIR}/merge_compile_func.sh
${TOOLS_DIR}/merge_configuration_func.sh
${TOOLS_DIR}/merge_softchain_func.sh

exit
