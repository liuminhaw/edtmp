#! /bin/bash
#
# This script is used to create a temporary file and open it in default text editor.
_EDTMP_DFLT_BASE_DIR="/tmp/edtmp"
_EDTMP_DFLT_NOTE_DIR="notes"
_EDTMP_DFLT_TMP_DIR="scratch"
_EDTMP_DFLT_FILE_EXT="tmp"
_VERSION="0.1.0"

# To customize directories and file extension, set following environment variables
# _EDTMP_BASE_DIR
# _EDTMP_NOTE_DIR
# _EDTMP_TMP_DIR
# _EDTMP_FILE_EXT

# ----------------------------------------------------------------------------
# Show script usage
# Outputs:
#   Write usage information to stdout
# ----------------------------------------------------------------------------
show_help() {
	cat <<EOF
Usage: ${0##*/} [OPTION]... [ACTION] [TARGET]

General options: 
    --help | -h         Display this help and exit
    --version | -v      Output version information and exit

Actions:
"scratch" is the default action if no action is provided.

- view [PATH]                 
    Open the path file or directory in the text editor
        
- note [-d --dir=directory] PATH      
    Open a named file (note file) or path in the text editor. 
    If a directory is provided, the file will be stored in that directory.
    If no directory is provided, the file will be stored in the default "notes" directory.

- scratch [-d --dir=directory] [EXTENSION]    
    Open a scratch file (temp file) in the text editor.
    If a directory is provided, the file will be stored in that directory.
    If no directory is provided, the file will be stored in the default "scratch" directory.
    If an extension is provided, the file will be created with that extension.
    If no extension is provided, the file will be created with the default "tmp" extension.

Customizations:
    The script can be customized by setting the following variables:
    _EDTMP_BASE_DIR: Base directory to store temporary files
    _EDTMP_NOTE_DIR: Default directory to store notes
    _EDTMP_TMP_DIR: Default directory to store temporary files
    _EDTMP_FILE_EXT: Default file extension for the scratch file if not explicitly set
EOF
}

# ----------------------------------------------------------------------------
# Set global variables and basic file structures for the script
#
# Globals:
#   _EDTMP_BASE_DIR: Base directory to store temporary files
#   _EDTMP_NOTE_DIR: Directory to store notes
#   _EDTMP_TMP_DIR: Directory to store temporary files
#   _EDTMP_FILE_EXT: Default file extension for the opened file if not explicitly set
# ----------------------------------------------------------------------------
setup() {
	if [[ -z "${_EDTMP_BASE_DIR}" ]]; then
		_EDTMP_BASE_DIR="${_EDTMP_DFLT_BASE_DIR}"
	fi

	if [[ -z "${_EDTMP_NOTE_DIR}" ]]; then
		_EDTMP_NOTE_DIR="${_EDTMP_DFLT_NOTE_DIR}"
	fi

	if [[ -z "${_EDTMP_TMP_DIR}" ]]; then
		_EDTMP_TMP_DIR="${_EDTMP_DFLT_TMP_DIR}"
	fi

	if [[ -z "${_EDTMP_FILE_EXT}" ]]; then
		_EDTMP_FILE_EXT="${_EDTMP_DFLT_FILE_EXT}"
	fi

	mkdir -p "${_EDTMP_BASE_DIR}"
}

# ----------------------------------------------------------------------------
# Check vim / nvim editor existence and set _EDITOR variable to it.
# nvim will be set as default editor if both vim and nvim are installed.
#
# This script is designed to work with vim / nvim to use their included feature
# and also that I use vim / nvim as my default text editor.
#
# Globals:
#  _EDITOR
#
# Returns:
#   1: vim or nvim editor is not installed
# ----------------------------------------------------------------------------
check_editor() {
	if ! which vim &>/dev/null && ! which nvim &>/dev/null; then
		echo "[ERROR] vim or nvim editor is not installed" 1>&2
		return 1
	fi
	if which nvim &>/dev/null; then
		_EDITOR="nvim"
	else
		_EDITOR="vim"
	fi
}

# ----------------------------------------------------------------------------
# Open the target file in the text editor.
#
# Globals:
#   _EDTMP_BASE_DIR
#   _EDITOR
#
# Arguments:
#   Target path to open in the text editor
#
# Returns:
#   1: General usage error
#   11: pushd or popd failure
# ----------------------------------------------------------------------------
run_editor() {
	if [[ ${#} -ne 1 ]]; then
		echo -e "[ERROR] Function ${FUNCNAME[0]} usage error" 1>&2
		return 1
	fi

	if [[ -z "${_EDITOR}" ]]; then
		echo -e "[ERROR] Editor is not set" 1>&2
		return 1
	fi

	local _target="${1}"
	local _current_path
	_current_path=$(pwd)

	pushd "${_EDTMP_BASE_DIR}" >/dev/null || return 11
	${_EDITOR} "${_target}"
	popd >/dev/null || return 11
}

# ----------------------------------------------------------------------------
# Open path in the text editor.
# If path is not provided, open the base directory.
#
# Globals:
#   _EDTMP_BASE_DIR
#   _EDITOR
#
# Arguments:
#   Path to open in the text editor
#
# Returns:
#   Non-zero if error occurs
# ----------------------------------------------------------------------------
view_file() {
	local _current_path
	_current_path=$(pwd)

	if [[ -z "${1}" ]]; then
		local _path="${_EDTMP_BASE_DIR}/."
	elif [[ -e "${_EDTMP_BASE_DIR}/${1}" ]]; then
		local _path="${_EDTMP_BASE_DIR}/${1}"
	fi

	if ! run_editor "${_path}"; then
		return
	fi
}

# ----------------------------------------------------------------------------
# Open a note file (file with specific filename) in the text editor.
#
# Globals:
#   _EDTMP_BASE_DIR
#   _EDTMP_NOTE_DIR
#   _EDITOR
#
# Arguments:
#   filepath to open in the text editor
#   directory to store the note file, use _EDTMP_NOTE_DIR if value is empty
#
# Returns:
#   Non-zero if error occurs
# ----------------------------------------------------------------------------
edit_note() {
	if [[ ${#} -ne 2 ]]; then
		echo -e "[ERROR] Function ${FUNCNAME[0]} usage error" 1>&2
		exit 1
	fi

	local _path="${1}"
	local _dir_opt="${2}"

	if [[ -z "${_path}" ]]; then
		echo -e "[ERROR] Invalid target" 1>&2
		exit 1
	fi
	if [[ -z "${_dir_opt}" ]]; then
		_dir_opt="${_EDTMP_NOTE_DIR}"
	fi

	local _note_path="${_EDTMP_BASE_DIR}/${_dir_opt}/${_path}"
	if ! mkdir -p "$(dirname "${_note_path}")"; then
		return 11
	fi

	if ! run_editor "${_note_path}"; then
		return
	fi

	if [[ -f "${_note_path}" && ! -s "${_note_path}" ]]; then
		rm -f "${_note_path}"
		return
	fi
}

# ----------------------------------------------------------------------------
# Open a scratch file (file with random name in format edtmp.XXXXXXXX.{ext} in the text editor.
#
# Globals:
#   _EDTMP_BASE_DIR
#   _EDTMP_TMP_DIR
#   _EDITOR
#
# Arguments:
#   file extension of the scratch file, use _EDTMP_FILE_EXT if value is empty
#   directory to store the scratch file, use _EDTMP_TMP_DIR if value is empty
# ----------------------------------------------------------------------------
edit_scratch() {
	if [[ ${#} -ne 2 ]]; then
		echo -e "[ERROR] Function ${FUNCNAME[0]} usage error" 1>&2
		exit 1
	fi

	local _file_ext="${1}"
	local _dir_opt="${2}"

	if [[ -z "${_file_ext}" ]]; then
		_file_ext="${_EDTMP_FILE_EXT}"
	fi
	if [[ -z "${_dir_opt}" ]]; then
		_dir_opt="${_EDTMP_TMP_DIR}"
	fi

	if ! mkdir -p "${_EDTMP_BASE_DIR}/${_dir_opt}"; then
		return 11
	fi

	local _tempfile
	_tempfile=$(mktemp "${_EDTMP_BASE_DIR}/${_dir_opt}/edtmp.XXXXXXXX.${_file_ext}")

	if ! run_editor "${_tempfile}"; then
		echo $?
		return
	fi

	if [[ ! -s "${_tempfile}" ]]; then
		rm -f "${_tempfile}"
		return
	fi
}

main() {
	# Basic setup
	setup

	# Check prerequisites: editor
	if ! check_editor; then
		exit 1
	fi

	local _dir_opt
	while :; do
		case ${1} in
		--help | -h)
			show_help
			exit
			;;
		--version | -v)
			echo "Version: ${_VERSION}"
			exit
			;;
		--dir | -d)
			if [[ "${2}" ]]; then
				_dir_opt=${2}
				shift
			else
				echo -e "[ERROR] '--dir' requires a non-empty option argument." 1>&2
				exit 1
			fi
			;;
		--dir=?*)
			_dir_opt=${1#*=} # Delete everything up to "=" and assign the remainder
			;;
		--dir=)
			echo -e "[ERROR] '--dir' requires a non-empty option argument." 1>&2
			exit 1
			;;
		-?*)
			echo -e "[WARN] Unknown option (ignored): ${1}" 1>&2
			exit 1
			;;
		*) # Default case: no more options
			break ;;
		esac

		shift
	done

	if [[ ${#} -eq 0 ]]; then
		local _action="scratch"
	elif [[ ${#} -eq 1 ]]; then
		local _action=${1}
	elif [[ ${#} -eq 2 ]]; then
		local _action=${1}
		local _target=${2}
	else
		echo -e "[ERROR] Invalid number of arguments." 1>&2
		exit 1
	fi

	case ${_action} in
	view)
		view_file "${_target}"
		;;
	note)
		edit_note "${_target}" "${_dir_opt}"
		;;
	scratch)
		edit_scratch "${_target}" "${_dir_opt}"
		;;
	*)
		echo -e "[ERROR] Invalid action: ${_action}" 1>&2
		exit 1
		;;
	esac
}

main "${@}"
