#!/bin/bash

# This script establishes an attested chain of log files.
# It is meant to be called by logrotate as a postrotate script

RAWLOGFILE=/var/log/payload_stderr.log.1
LOGFILE=${RAWLOGFILE}.sanitized
LASTHASHFILE=/var/log/payload_lasthash # see run.sh
CONTAINER=teehee

# Sanitize the log file.
python3 redacter.py $RAWLOGFILE $LOGFILE

# Append the hash of last log file
LASTHASH=$(cat $LASTHASHFILE)
echo Last Hash: $LASTHASH >> $LOGFILE

# Append hash of current log file
HASH=$(sha256sum $LOGFILE)
echo New Hash: $HASH >> $LOGFILE

# Overwrite last hash
echo $HASH > $LASTHASHFILE

# Create a remote attestation with this hash and append that too
PAYLOAD="{\"report_data\": \"$(echo -n $HASH | od -A n -t x1 | tr -d ' \n')\"}"
ATTEST=$(curl -X POST --unix-socket /var/run/tappd.sock -d "$PAYLOAD" http://localhost/prpc/Tappd.TdxQuote?json)
echo Attestation: $ATTEST >> $LOGFILE

# Send the log file to a remote service
# TODO: this could be robust, ideally try several options,
# including passing directly to the host
az storage blob upload --connection-string $AZURE_BLOB_STRING --container-name $CONTAINER --content-type "text/plain" --file $LOGFILE --name "logs/log_$(date -u +"%Y-%m-%dT%H-%M-%SZ").log"
az storage blob upload --connection-string $AZURE_BLOB_STRING --container-name $CONTAINER --content-type "text/plain" --file $RAWLOGFILE --name "logs/redactedlog_$(date -u +"%Y-%m-%dT%H-%M-%SZ").log"
