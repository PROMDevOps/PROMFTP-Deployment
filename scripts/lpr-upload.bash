#!/bin/bash

FILE_TO_UPLOAD=$1

. ./export.bash PROD

if [[ ${FILE_TO_UPLOAD} == "" ]]; 
then
    FILE_TO_UPLOAD="/c/Users/User/Desktop/TICKET-001.20230829_1236.jpg"
fi

curl -s -H "Authorization: Bearer ${LPR_TOKEN}" -F "image=@${FILE_TO_UPLOAD}" ${LPR_ENDPOINT}
