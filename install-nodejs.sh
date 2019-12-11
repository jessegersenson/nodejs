#!/bin/bash

set -e
set -o pipefail
set -o nounset

#### DESCRIPTION: script to install nodejs on linux ####

cd /tmp
VERSION="$1" # VERSION='v12.13.1'
DISTRO="linux-x64"
USR_BIN='/usr/bin'

FILE="node-${VERSION}-${DISTRO}.tar.gz"

function check_for_linux(){
	if [[ ! $(uname -s) == 'Linux' ]]
	then
		echo "ERROR: script can not run on $(uname -s)"
		echo "$0 FAILED. This script can only run on linux systems"
		exit
	fi

}

function get_file(){
	FILE_NAME="$1"
	URL="$2"
	echo "INFO: wget $URL and save as $FILE_NAME"
	if [[ $(wget -q -O "${FILE_NAME}" "$URL") -eq 0 ]]
	then
		echo "SUCCESS: $URL downloaded"
	else
		echo "ERROR: $URL not downloaded. Wget in script $0 returned error code: $?"
		exit
	fi

}

function confirm_checksum(){
	echo "INFO: confirm checksum"
	CHECKSUM_FILE="${VERSION}-SHASUMS256.txt"
	get_file "$CHECKSUM_FILE" "https://nodejs.org/dist/${VERSION}/SHASUMS256.txt"
	CHECKSUM_EXPECTED=$(grep "$FILE" "${CHECKSUM_FILE}" | cut -f1 -d" ")
	CHECKSUM_ACTUAL=$(sha256sum "$FILE" | cut -f1 -d" ")

	#### check checksum ####
	if [[ ! $CHECKSUM_ACTUAL == "$CHECKSUM_EXPECTED" ]]
	then 
		echo "ERROR: sha256sum of $FILE ($CHECKSUM_ACTUAL) didn't match $CHECKSUM_EXPECTED. Exiting"
		exit
	else
		echo "SUCCESS: checksums match"
	fi

}

check_for_linux

get_file "$FILE" "https://nodejs.org/dist/${VERSION}/${FILE}"
confirm_checksum

mkdir -p "${USR_BIN}/nodejs"

tar -zxvf "$FILE" -C ${USR_BIN}/nodejs

ln -sf "${USR_BIN}/nodejs/node-${VERSION}-linux-x64/bin/npm" "${USR_BIN}/npm"
ln -sf "${USR_BIN}/nodejs/node-${VERSION}-linux-x64/bin/node" "${USR_BIN}/node"

echo "INFO: Success. Installed ${USR_BIN}/npm and ${USR_BIN}/node ${VERSION}"
echo "INFO: consider 'npm install -g npm@6.9.0' or 'npm install -g npm@6.13.2'"
rm -rf /tmp/*
