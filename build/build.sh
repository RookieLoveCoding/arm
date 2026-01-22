#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
ROOT_PATH="$(dirname "${SCRIPT_DIR}")"

if [ ! -d "./temp" ]; then
    mkdir temp
fi

cd temp && rm -rf *
cmake ${ROOT_PATH}
make
cp *.elf ${ROOT_PATH}/build/