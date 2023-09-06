#!/bin/bash

# ./sftp.bash xxxx.jpg 0001 2023-08-28 <dev|prod>

SRC_FILE=$1
EQUIPMENT_ID=$2
DATE_STAMP=$3
ENV=$4

SCRIPT_FILE=script.txt

. ./export.bash ${ENV}

cat << EOF > ${SCRIPT_FILE}
option batch continue
open sftp://${SFTP_USER}:${SFTP_PASSWORD}@${HOST_NAME}:2022
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
