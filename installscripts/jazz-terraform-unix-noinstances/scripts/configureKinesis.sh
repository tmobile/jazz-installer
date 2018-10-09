#!/bin/bash

jenkinsjsonpropsfile=$4

sed -i "s|{KINESIS_LOGS_STREAM_DEV}|$1|g" "$jenkinsjsonpropsfile"
sed -i "s|{KINESIS_LOGS_STREAM_STG}|$2|g" "$jenkinsjsonpropsfile"
sed -i "s|{KINESIS_LOGS_STREAM_PROD}|$3|g" "$jenkinsjsonpropsfile"
