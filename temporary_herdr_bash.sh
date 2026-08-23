#!/bin/sh

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec /bin/bash --rcfile "$script_dir/.bashrc" -i
