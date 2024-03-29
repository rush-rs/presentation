#!/bin/sh
# This file is used to download used git dependencies like tree-sitter parsers or the rush project.

set -e

mkdir -p deps

fetch_repo() {
    if ! [ -d "deps/$2" ]; then
        git clone "https://github.com/$1/$2.git" "deps/$2"
    else
        cd "deps/$2"
        git pull
        cd ../..
    fi
}

# TODO: create a Dockerfile
#install_pacman ttf-fira-sans

fetch_repo nvim-treesitter nvim-treesitter &
fetch_repo tree-sitter tree-sitter-rust &
# fetch_repo tree-sitter tree-sitter-bash &
# fetch_repo tree-sitter tree-sitter-c &
fetch_repo RubixDev ebnf &
fetch_repo RubixDev tree-sitter-llvm &
fetch_repo rush-rs tree-sitter-rush &
fetch_repo rush-rs tree-sitter-asm &
fetch_repo rush-rs tree-sitter-hexdump &
fetch_repo rush-rs tree-sitter-wasm &
fetch_repo rush-rs rush &
fetch_repo rush-rs paper &

wait
echo "All dependencies fetched."
