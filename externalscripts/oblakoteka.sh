#!/bin/bash

# Check number of parameters
if [[ "$#" -ne 3 ]]; then
    echo "Usage: ${0} <USERNAME> <PASSWORD> <balance|blockdate>" >&2
    exit 2
fi

# Set parameters
USERNAME=${1}
PASSWORD=${2}
COOKIE="/tmp/oblakoteka_${USERNAME}.cookie"
REQ=${3}
URL="https://cp.oblakoteka.ru"

# Delete old cookies and LogIn
rm -f ${COOKIE} && \
curl -s -X POST \
  -F "UserName=${USERNAME}" \
  -F "Password=${PASSWORD}" \
  -F "SmsCode=" \
  -b ${COOKIE} -c ${COOKIE} \
  ${URL}/ > /dev/null

# Get values from cabinet
case "${REQ}" in
  "balance")
    curl -s \
      -b ${COOKIE} -c ${COOKIE} \
      ${URL}/Account/CalculateAvailableAccountSum \
    | jq .Amount \
    | grep -o "[0-9,-]*" \
    | sed -e 's/,/./g'
    ;;
  "blockdate")
    curl -s \
      -b ${COOKIE} -c ${COOKIE} \
      ${URL}/Account/PredictUserBlockDate \
    | jq .blockingDate \
    | grep -o "[0-9]*"
    ;;
esac

# LogOut
curl -s \
  -b ${COOKIE} -c ${COOKIE} \
  ${URL}/Account/LogOff > /dev/null
