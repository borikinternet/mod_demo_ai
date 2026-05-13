#!/bin/bash

set -euo pipefail

role=${1:?Usage: ha_lab_fs.sh <primary|backup>}
LAB_ROOT=${LAB_ROOT:-/opt/fs-ha-lab}
root="${LAB_ROOT}/${role}"
db="${LAB_ROOT}/db"

if [ "${role}" = "callee" ]; then
	db="${root}/db"
	mkdir -p "${db}"
fi

exec freeswitch \
	-nonat \
	-ncwait \
	-conf "${root}/conf" \
	-log "${root}/log" \
	-run "${root}/run" \
	-db "${db}" \
	-mod /usr/lib/freeswitch/mod \
	-recordings "${root}/recordings" \
	-storage "${root}/storage" \
	-cache "${root}/cache" \
	-temp "${root}/temp" \
	-sounds "${root}/sounds" \
	-scripts "${root}/scripts" \
	-htdocs "${root}/htdocs" \
	-grammar "${root}/grammar" \
	-certs "${root}/certs"