#!/bin/bash

if [ $# -ne 0 ]
then
   echo "Usage: $0 <container>" 1>&2
   exit 1
fi

set -euo pipefail

CONTAINER=$1; shift

echo -n | sudo tee $(docker inspect --format='{{.LogPath}}' "$CONTAINER")
