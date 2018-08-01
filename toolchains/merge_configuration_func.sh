#!/bin/bash
# Author  : chinatree <chinatree2012@gmail.com>
# Date    : 2014-01-28
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
TYPE="configuration"
MERGE_FUNC_DIR="${PROJECT_ROOT}/func/${TYPE}"
DST_FUNC_SH="${COMMON_DIR}/${TYPE}_func.sh"

if [ ! -f "${COMMON_DIR}/functions.sh" ];
then
    echo "The common function file ${COMMON_DIR}/functions.sh not exists, please check it and try again!"
    exit 1
else
    . "${COMMON_DIR}"/functions.sh
fi

if [ -f "${DST_FUNC_SH}" ];then
    mv "${DST_FUNC_SH}" "${DST_FUNC_SH}".bak
fi

merge() {
    cd "${MERGE_FUNC_DIR}"

    echo '#!/bin/bash' > "${DST_FUNC_SH}"
    echo -n "Mergeing ${TYPE} func ... "
    for func in $(ls *.func 2>/dev/null)
    do
        if [ -f "${func}" ];
        then
            cat "${func}" | sed '1,1d' >> "${DST_FUNC_SH}"
        fi
    done
    get_exit_code $?
    chmod +x "${DST_FUNC_SH}"
}

merge

exit
