#! /bin/bash
#
# This script is used to create a temporary file and open it in default text editor.
_DEFAULT_BASE_DIR="/tmp"
_DEFAULT_FILE_EXT="tmp"

# Custom set base directory
# _BASE_DIR=""

if [[ -z "${EDITOR}" ]]; then
    echo "EDITOR environment variable is not set"
    exit 1
fi

if [[ -z "${_BASE_DIR}" ]]; then
    _BASE_DIR="${_DEFAULT_BASE_DIR}"
fi 

if [[ "${#}" -eq 0 ]]; then
    _file_ext="${_DEFAULT_FILE_EXT}"
else
    _file_ext="${1}"
fi

# Create temporary file directory
mkdir -p "${_BASE_DIR}/edtmp"

# Create a temporary file
_tempfile=$(mktemp "${_BASE_DIR}/edtmp/edtmp.XXXXXXXX.${_file_ext}")

# Open the temporary file in a text editor
# /home/haw/bin/nvim "${_tempfile}"
${EDITOR} "${_tempfile}"

# Check temporaray file size and delete it if it is empty
if [[ ! -s "${_tempfile}" ]]; then
    rm -f "${_tempfile}"
    exit 0
fi

echo "Temp file: ${_tempfile} created"

