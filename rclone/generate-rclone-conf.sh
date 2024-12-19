#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <input_config_file>"
    exit 1
fi

INPUT_FILE="$1"
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found!"
    exit 1
fi

# Replace variables in the file and output to stdout
sed -E 's/\{([A-Z_][A-Z0-9_]*)\}/\$\1/g' "$INPUT_FILE" | envsubst
