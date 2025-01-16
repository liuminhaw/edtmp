# edtmp
Edit temp, a simple note taking script to open temporary files and notes in the text editor.

## Usage
```
Usage: edtmp.sh [OPTION]... [ACTION] [TARGET]

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
```

