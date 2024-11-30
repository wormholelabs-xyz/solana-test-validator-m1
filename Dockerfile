FROM --platform=linux/arm64/v8 ubuntu:20.04@sha256:4489868cec4ea83f1e2c8e9f493ac957ec1451a63428dbec12af2894e6da4429 AS build

RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y curl wget libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang cmake make libprotobuf-dev protobuf-compiler

# --default-toolchain must match https://github.com/anza-xyz/agave/blob/v2.0.17/rust-toolchain.toml
# alternatively, this could do something like the following
# RUN source solana/ci/rust-version.sh && \
#     curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain "$rust_stable"
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain "1.78.0" && . $HOME/.cargo/env && rustup component add rustfmt
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain "1.73.0" && . $HOME/.cargo/env && rustup component add rustfmt

ENV PATH=/root/.cargo/bin:$PATH

WORKDIR /build

# version 2.0.17 is incompatible with the existing devnet_setup.sh
# ENV solana_version=2.0.17
ENV solana_version=1.17.29

RUN wget https://github.com/anza-xyz/agave/archive/refs/tags/v${solana_version}.tar.gz

RUN tar -xf v${solana_version}.tar.gz

WORKDIR /build/agave-${solana_version}

# the full build OOMed with 24GB RAM allocated to Docker, so use --validator-only to slim it down and speed it up
# except that the following command apparently didn't build solana-test-validator
# RUN ./scripts/cargo-install-all.sh . --validator-only
# so just explicitly build solana-test-validator
RUN ./cargo build --profile release --bin solana-test-validator
RUN mkdir bin && cp target/release/solana-test-validator /bin/solana-test-validator

FROM --platform=linux/arm64/v8 ubuntu:20.04@sha256:4489868cec4ea83f1e2c8e9f493ac957ec1451a63428dbec12af2894e6da4429 AS export

COPY --from=build /bin/solana-test-validator /bin/
