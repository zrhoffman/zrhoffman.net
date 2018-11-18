#!/usr/bin/env sh
set -eu;
pwd="$(
    readlink -f "$(
        dirname "$(
            readlink -f "$0";
        )";
    )";
)"'/..';
cd "$pwd";

docker_tag=build-site;
docker pull rust:slim;
<<'DOCKERFILE' docker build --tag="$docker_tag" -
FROM	rust:slim

LABEL   name="Rust build environment"\
        version="0.0.0"

ENV     PATH="$PATH":/usr/local/cargo/bin

RUN     set -eu;\
        apt-get update;\
        apt-get install -y musl-tools;\
        rustup default nightly;\
        rustup toolchain list | grep '^[0-9].*' | xargs rustup toolchain uninstall;\
        rustup target add x86_64-unknown-linux-musl;\
        useradd --create-home --uid=1000 builder;
DOCKERFILE

mount=/tmp/project;
<<'BUILD' docker run --rm -iu builder --mount=type=bind,source="$pwd",target="$mount" "$docker_tag" sh
set -eu;
cd /tmp/project;
platform='x86_64-unknown-linux-musl';
cargo build --target="$platform" --release;
out_name='target/'"$platform"'/release/'"$(
    cargo metadata --no-deps --format-version=1 |
        grep -om1 '"name":"[^"]\+"' |
        head -n1 |
        awk -F'"' '{print $(NF - 1)}'
)";
ln -f "$out_name" target/site;
cp -r templates target;
BUILD

echo 'Build complete.';
