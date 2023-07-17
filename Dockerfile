# This Dockerfile defines an image for a container that can run
# WasmEdge with Wasi-NN and underlying PyTorch

# See the examples folder for scripts that use this.

# Download base image ubuntu 20.04
FROM ubuntu:20.04

# Install needed basic tools
RUN apt update && apt install -y \
    curl \
    git \
    python3 \
    unzip

# Install Rust with wasm32-wasi support
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup update && rustup target add wasm32-wasi

# Install wasmedge with pytorch plugin
RUN curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash -s -- --plugins wasi_nn-pytorch
ENV PATH="/root/.wasmedge/bin:${PATH}"

# Download and install pytorch
ARG PYTORCH_VERSION="1.8.2"
ARG PYTORCH_ABI="libtorch-cxx11-abi"

RUN curl -s -L -O --remote-name-all https://download.pytorch.org/libtorch/lts/1.8/cpu/${PYTORCH_ABI}-shared-with-deps-${PYTORCH_VERSION}%2Bcpu.zip && \
    unzip -q "${PYTORCH_ABI}-shared-with-deps-${PYTORCH_VERSION}%2Bcpu.zip" && \
    rm -f "${PYTORCH_ABI}-shared-with-deps-${PYTORCH_VERSION}%2Bcpu.zip"

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/libtorch/lib
