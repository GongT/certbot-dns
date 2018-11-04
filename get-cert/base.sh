#!/usr/bin/env bash

if [ -n "${BASE_SOURCED}" ]; then
	return
fi
export BASE_SOURCED=true

export INDENT=""
export TAB="$(echo -e "\t")"
export CWD=$(pwd)
export ROOT=$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")
cd "${ROOT}"

set -a
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
		builtin echo -e "\e[38;5;9m$*\e[0m" >&2
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

function load-config() {
	local CFG="$1"
	local FORCE="$2"
	if [ -e "$CFG" ] ; then
		set -a
		echo "load config file: $CFG"
		source "$CFG" || die "config file wrong."
		set +a
	elif [ -n "$FORCE" ] ; then
		die "config file not found."
	else
		return 1
	fi
}

function load-config-file-arg() {
	if [ -z "$1" ]; then
		local CFG="config.sh"
	else
		local CFG="${1/.sh}.sh"
	fi
	if [ "${CFG:0:1}" = "/" ]; then
		load-config "$CFG" force
	else
		if ! load-config "$CWD/$CFG" ; then
			load-config "$ROOT/$CFG" force
		fi
	fi
}

function dry-run-arg() {
	export DRY_RUN='--staging'
}

function load-arguments() {
	if [ -z "$1" ]; then
		usage
	fi
	export DRY_RUN=
	while getopts ":df:" o; do
		case "${o}" in
		d)
			dry-run-arg
			;;
		f)
			local CONFIG="$OPTARG"
			;;
		\?)
			declare -p | grep OPT
			usage "Invalid option: -$OPTARG"
			exit 1
			;;
		:)
			usage "Option -$OPTARG requires an argument."
			;;
		*)
			usage
			;;
		esac
	done
	shift $(expr $OPTIND - 1 )
	
	export ARG_HOST=$1
	
	shift
	EXTRA_ARGS=("$@")
	
	load-config-file-arg "$CONFIG"
}
set +a
