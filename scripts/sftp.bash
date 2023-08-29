#!/bin/bash

# ./sftp.bash xxxx.jpg 0001 2023-08-28

SRC_FILE=$1
EQUIPMENT_ID=$2
DATE_STAMP=$3

SCRIPT_FILE=script.txt

. ./export.bash

cat << EOF > ${SCRIPT_FILE}
option batch continue
open sftp://${SFTP_USER}:${SFTP_PASSWORD}@lp.promjodd.prom.co.th:2022
cd /ftp

mkdir ${EQUIPMENT_ID}
cd ${EQUIPMENT_ID}
mkdir ${DATE_STAMP}
cd ${DATE_STAMP}

put ${SRC_FILE}
exit
EOF

winscp.com //script=${SCRIPT_FILE}
rm ${SCRIPT_FILE}
