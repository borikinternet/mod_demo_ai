#!/bin/bash

set -euo pipefail

if [ "$#" -eq 0 ]; then
	echo "Usage: ha_lab_cli.sh <FreeSWITCH API command>" >&2
	exit 2
fi

exec fs_cli -H 127.0.0.1 -P 8021 -p ClueCon -x "$*"