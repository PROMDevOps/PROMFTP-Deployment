#!/bin/bash

# ./sftp-hook-test.bash test.jpg <dev|prod>

SRC_IMAGE=$1
ENV=$2

TICKET_ID=$(date +"%s")

# Read AUTH_USER and AUTH_PASSWORD from export.bash file
. ./export.bash ${ENV}

FILE_NAME=$(basename -- "${SRC_IMAGE}")
EXTENSION="${FILE_NAME##*.}"

DAT_TEMPLATE=template.json
COMPANY_ID="XXX001"
BRANCH_ID="BR-001"
EQUIPMENT_ID="T001"

DATE_STAMP=$(date -I)
TIME_STAMP=$(date --utc +%FT%T.%3NZ)
REF_ID="${TICKET_ID}"
UPLOADED_IMAGE_NAME="${REF_ID}.${DATE_STAMP}.${EXTENSION}"
UPLOADED_PATH="/ftp/${EQUIPMENT_ID}/${DATE_STAMP}/${UPLOADED_IMAGE_NAME}" # Uploaded file should be foldered by ${DATE_STAMP}

cp ${SRC_IMAGE} ${UPLOADED_IMAGE_NAME}

UPLOADED_SIZE=$(wc -c < ${UPLOADED_IMAGE_NAME})

echo "### Start uploading file [${UPLOADED_IMAGE_NAME}] [${UPLOADED_SIZE} bytes] to FTP server..."
START_EPOCH=$(date +%s%N | cut -b1-13)
./sftp.bash ${UPLOADED_IMAGE_NAME} ${EQUIPMENT_ID} ${DATE_STAMP} ${ENV}
END_EPOCH=$(date +%s%N | cut -b1-13)
UPLOADED_TIME_MS=$((END_EPOCH-START_EPOCH))
echo "### Done uploading file [${UPLOADED_IMAGE_NAME}] [${UPLOADED_TIME_MS} ms] to FTP server"

rm ${UPLOADED_IMAGE_NAME}

echo "### Start calling webhook for [${UPLOADED_IMAGE_NAME}]..."
cat << EOF > ${DAT_TEMPLATE}
{
  "RefId": "${REF_ID}",
  "UploadPath": "${UPLOADED_PATH}",
  "UploadSize": "${UPLOADED_SIZE}",
  "UploadTimeMs": "${UPLOADED_TIME_MS}",
  "CompanyId": "${COMPANY_ID}",
  "BranchId": "${BRANCH_ID}",
  "EquipmentId": "${EQUIPMENT_ID}",
  "StartDtm": "${TIME_STAMP}",
  "UploadUser": "${SFTP_USER}"
}
EOF

curl -X POST https://${HOST_NAME}/file-uploaded-notify -s \
   -H "Content-Type: application/json" \
   -H "Prom-Ref-ID: ${REF_ID}" \
   -H "Prom-Upload-Path: ${UPLOADED_PATH}" \
   -H "Prom-Upload-Size: ${UPLOADED_SIZE}" \
   -H "Prom-Upload-TimeMs: ${UPLOADED_TIME_MS}" \
   -H "Prom-Company: ${COMPANY_ID}" \
   -H "Prom-Branch: ${BRANCH_ID}" \
   -H "Prom-Equipment-ID: ${EQUIPMENT_ID}" \
   -H "Prom-Start-Timestamp: ${TIME_STAMP}" \
   -H "Prom-Upload-User: ${SFTP_USER}" \
   -u "${AUTH_USER}:${AUTH_PASSWORD}" \
   -d "@${DAT_TEMPLATE}"

echo "### Done calling webhook for [${UPLOADED_IMAGE_NAME}]..."
