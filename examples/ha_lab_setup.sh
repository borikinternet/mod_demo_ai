#!/bin/bash

set -euo pipefail

LAB_ROOT=${LAB_ROOT:-/opt/fs-ha-lab}
CONF_SRC=${CONF_SRC:-/usr/share/freeswitch/conf/vanilla}

rm -rf "${LAB_ROOT}"

mkdir -p "${LAB_ROOT}/db"
mkdir -p "${LAB_ROOT}/baresip-a" "${LAB_ROOT}/baresip-b"


prepare_role()
{
	local role=$1
	local internal_port=${2:-5060}
	local external_port=${3:-5080}
	local event_socket_port=${4:-8021}
	local root="${LAB_ROOT}/${role}"

	mkdir -p "${root}"
	cp -a "${CONF_SRC}" "${root}/conf"
	mkdir -p \
		"${root}/log" \
		"${root}/run" \
		"${root}/recordings" \
		"${root}/storage" \
		"${root}/cache" \
		"${root}/temp" \
		"${root}/sounds" \
		"${root}/scripts" \
		"${root}/htdocs" \
		"${root}/grammar" \
		"${root}/certs"

	sed -i -E \
		-e 's#(data="local_ip_v4=)[^"]+#\1127.0.0.1#g' \
		-e 's#(data="domain=)[^"]+#\1127.0.0.1#g' \
		-e 's#(data="external_sip_ip=)[^"]+#\1127.0.0.1#g' \
		-e 's#(data="external_rtp_ip=)[^"]+#\1127.0.0.1#g' \
		-e "s#(data=\"internal_sip_port=)[^\"]+#\\1${internal_port}#g" \
		-e "s#(data=\"external_sip_port=)[^\"]+#\\1${external_port}#g" \
		"${root}/conf/vars.xml"

	sed -i -E \
		-e "s#(<param name=\"listen-port\" value=\")[^\"]+#\\1${event_socket_port}#g" \
		"${root}/conf/autoload_configs/event_socket.conf.xml"
}

prepare_role primary
prepare_role backup
prepare_role callee 5070 5090 8022

prepare_baresip()
{
	local role=$1
	local user=$2
	local port=$3
	local root="${LAB_ROOT}/baresip-${role}"

	cat >"${root}/config" <<EOF_CONFIG
poll_method		epoll
sip_listen		127.0.0.1:${port}
call_local_timeout	120
call_max_calls		4
audio_player		aufile,/dev/null
audio_source		ausine,440
module_path		/usr/lib/baresip/modules
module			stdio.so
module			g711.so
module			aufile.so
module			ausine.so
EOF_CONFIG
	cat >"${root}/accounts" <<EOF_ACCOUNTS
<sip:${user}@127.0.0.1>;auth_user=${user};auth_pass=1234;answermode=auto;regint=60
EOF_ACCOUNTS
	: >"${root}/contacts"
}

prepare_baresip a 1000 16160
prepare_baresip b 1001 16161

echo "Prepared FreeSWITCH HA lab at ${LAB_ROOT}"