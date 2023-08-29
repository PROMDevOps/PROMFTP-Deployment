#!/bin/bash

# Read AUTH_USER and AUTH_PASSWORD from export.bash file
. ./export.bash

DAT_TEMPLATE=template.json
#TICKET-001.20230829_1236.jpg

DATE_STAMP=$(date -I)
TIME_STAMP=$(date --utc +%FT%T.%3NZ)
REF_ID="TICKET-001"
EQUIPMENT_ID="T001"
UPLOADED_PATH="TICKET-001.20230829_1236.jpg" # Uploaded file should be foldered by ${DATE_STAMP}
UPLOADED_SIZE=2500
UPLOADED_TIME_MS=560
COMPANY_ID="XXX001"
BRANCH_ID="BR-001"

cat << EOF > ${DAT_TEMPLATE}
{
  "RefId": "${REF_ID}",
  "UploadPath": "${UPLOADED_PATH}",
  "UploadSize": "${UPLOADED_SIZE}",
  "UploadTimeMs": "${UPLOADED_TIME_MS}",
  "CompanyId": "${COMPANY_ID}",
  "BranchId": "${BRANCH_ID}",
  "EquipmentId": "${EQUIPMENT_ID}",
  "StartDtm": "${TIME_STAMP}"
}
EOF

curl -X POST https://lp.promjodd.prom.co.th/ -s \
   -H "Content-Type: application/json" \
   -H "Prom-Ref-ID: ${REF_ID}" \
   -H "Prom-Upload-Path: ${UPLOADED_PATH}" \
   -H "Prom-Upload-Size: ${UPLOADED_SIZE}" \
   -H "Prom-Upload-TimeMs: ${UPLOADED_TIME_MS}" \
   -H "Prom-Company: ${COMPANY_ID}" \
   -H "Prom-Branch: ${BRANCH_ID}" \
   -H "Prom-Equipment-ID: ${EQUIPMENT_ID}" \
   -H "Prom-Start-Timestamp: ${TIME_STAMP}" \
   -u "${AUTH_USER}:${AUTH_PASSWORD}" \
   -d "@${DAT_TEMPLATE}"
