#!/usr/bin/env bash

INDENT=""
TAB="$(echo -e "\t")"

function indent() {
	if [ "$1" = "-" ]; then
		INDENT="${INDENT:1}"
	elif [ "$1" = "+" ]; then
		INDENT="${INDENT}${TAB}"
	else
		die "indent require an argument '+/-'"
	fi
}
function echoo() {
	builtin echo "$@"
}
function echo() {
	builtin echo "${INDENT}""$@" >&2
}
function echoe() {
	builtin echo -e "${INDENT}""$@" >&2
}
function echone() {
	builtin echo -ne "${INDENT}""$@" >&2
}
function info() {
	echoe "\e[38;5;14m$@\e[0m"
}
function die() {
	if [ -n "$*" ]; then
		echoe "\e[38;5;9m""$@""\e[0m" >&2
	fi
	exit 1
}

function usage() {
	if [ -n "$*" ]; then
		echoe "$@"
	fi
	echoe "Usage:
	$0 [-d] [-f config-file] <sub-domain>
	
	-d: staging mode
	-f: config file (default=get from environment)
Example:
	$0 -f ./config-example.sh -d www
"
	die
}

function askYN() {
	echo "${@}"
	local TEST
	while true; do
		read -p "输入 Y/N > " TEST
		if [ "${TEST}" = "y" -o "${TEST}" = "Y" ]; then
			return 0
		elif [ "${TEST}" = "n" -o "${TEST}" = "N" ]; then
			return 1
		fi
	done
}

function command_exists() {
	command -v $1 &>/dev/null
}

function check_variables() {
	while [ "$#" -gt 0 ]; do
		if [ "${!1+x}" != "x" ] ; then
			die "config failed: variable $1 does not exists."
		fi
		shift
	done
}
