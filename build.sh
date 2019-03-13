#!/bin/bash
# A basic build script that *should* build the system in static release mode
# Break on first error
set -e
# First, build the local image
docker build -t crcophony_builder .
docker run --rm -it -v $PWD:/app -w /app crcophony_builder shards build --static --release src/crcophony.cr
