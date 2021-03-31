#!/usr/bin/env bash

set -e

if which jq >/dev/null; then
    echo "jq is installed."
else
    echo "error: jq is not installed. Installing jq. Try again!"
    brew install jq
fi

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'

echo "Target version - ${BLUE}$1${NC}"
echo "------------------AEPEdgePersonalization-------------------"
PODSPEC_VERSION_IN_AEPEdgePersonalization=$(pod ipc spec AEPEdgePersonalization.podspec | jq '.version' | tr -d '"')
echo "Local podspec version - ${BLUE}${PODSPEC_VERSION_IN_AEPEdgePersonalization}${NC}"
SOURCE_CODE_VERSION_IN_AEPEdgePersonalization=$(cat ./Sources/AEPEdgePersonalization/PersonalizationConstants.swift | egrep '\s*EXTENSION_VERSION\s*=\s*\"(.*)\"' | ruby -e "puts gets.scan(/\"(.*)\"/)[0] " | tr -d '"')
echo "Source code version - ${BLUE}${SOURCE_CODE_VERSION_IN_AEPEdgePersonalization}${NC}"

if [[ "$1" == "$PODSPEC_VERSION_IN_AEPEdgePersonalization" ]] && [[ "$1" == "$SOURCE_CODE_VERSION_IN_AEPEdgePersonalization" ]]; then
    echo "${GREEN}Pass!${NC}"
else
    echo "${RED}[Error]${NC} Versions do not match!"
    exit -1
fi
exit 0
