FROM ubuntu:20.04@sha256:8e5c4f0285ecbb4ead070431d29b576a530d3166df73ec44affc1cd27555141b AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y curl wget libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang cmake make libprotobuf-dev protobuf-compiler

WORKDIR /build

ARG SOLANA_CLI

RUN wget "https://github.com/anza-xyz/agave/archive/refs/tags/v${SOLANA_CLI}.tar.gz"

RUN tar -xf v${SOLANA_CLI}.tar.gz

WORKDIR /build/agave-${SOLANA_CLI}

RUN bash -c ". ci/rust-version.sh && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain \$rust_stable && \
    . $HOME/.cargo/env && \
    rustup component add rustfmt"

ENV PATH=/root/.cargo/bin:$PATH

RUN ./cargo build --profile release --bin solana-test-validator

RUN mkdir bin && cp target/release/solana-test-validator /bin/solana-test-validator

FROM ubuntu:20.04@sha256:8e5c4f0285ecbb4ead070431d29b576a530d3166df73ec44affc1cd27555141b AS export

COPY --from=build /bin/solana-test-validator /bin/
