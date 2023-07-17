#!/usr/bin/env bash

# Make sure we're running in the script's location
DOCKER_FILE="$(realpath $(dirname $BASH_SOURCE)/../Dockerfile)"

echo "Building WasmEdge-wasi-nn local image..."
docker build -t wasmedge-wasi-nn-local -f ../Dockerfile ..


echo "Getting WasmEdge-WASINN-examples..." 
TMP_WASINN_WORKDIR=$(mktemp -d)
git clone --depth 1 \
  https://github.com/second-state/WasmEdge-WASINN-examples.git \
  ${TMP_WASINN_WORKDIR}/WasmEdge-wasi-nn


echo "Running the pytorch-mobilenet-image example..."
set -x
docker run \
    --volume ${TMP_WASINN_WORKDIR}/WasmEdge-wasi-nn/pytorch-mobilenet-image:/example \
    --tty \
    --rm \
    --interactive \
    --workdir /example \
    wasmedge-wasi-nn-local \
    wasmedge \
        --dir .:. \
        wasmedge-wasinn-example-mobilenet-image.wasm \
        mobilenet.pt \
        input.jpg
