# Download base image ubuntu 20.04
FROM ubuntu:20.04


RUN apt update
# Install git
RUN apt install -y git

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

CMD source "$HOME/.cargo/env"
CMD rustup target add wasm32-wasi

# Install wasmedge with pytorch plugin
RUN curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash -s -- --plugins wasi_nn-pytorch

# Run this command to make the installed binary available in the current session.
CMD source "$HOME/.wasmedge/env"

# Export environment variable for pytorch 1.8.2
RUN export PYTORCH_VERSION="1.8.2"
RUN export PYTORCH_ABI="libtorch-cxx11-abi"

CMD curl -s -L -O --remote-name-all https://download.pytorch.org/libtorch/lts/1.8/cpu/${PYTORCH_ABI}-shared-with-deps-${PYTORCH_VERSION}%2Bcpu.zip
CMD unzip -q "${PYTORCH_ABI}-shared-with-deps-${PYTORCH_VERSION}%2Bcpu.zip"
CMD rm -f "${PYTORCH_ABI}-shared-with-deps-${PYTORCH_VERSION}%2Bcpu.zip"
CMD export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$(pwd)/libtorch/lib

CMD git clone https://github.com/second-state/WasmEdge-WASINN-examples.git

WORKDIR /WasmEdge-WASINN-examples/pytorch-mobilenet-image

CMD wasmedge --dir .:. wasmedge-wasinn-example-mobilenet-image.wasm mobilenet.pt input.jpg
