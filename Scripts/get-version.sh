#!/bin/sh

set -e

REGEX="static let current = \"([0-9]+.[0-9]+.[0-9]+)\""
while IFS= read -r line; do
    if [[ $line =~ $REGEX ]]
    then
        echo "${BASH_REMATCH[1]}"
        break
    fi
done < Sources/CloakKit/Version/Version.swift