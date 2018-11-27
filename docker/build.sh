#!/usr/bin/env bash
set -eu;

set +u;

if [[ ! -v "$nobuild" ]]
then
    nobuild='';
fi;

set -u;

pwd="$(
    readlink -f "$(
        dirname "$(
            readlink -f "$0";
        )";
    )";
)"'/..';

(
cd "$pwd";

if [[ -z "$nobuild" ]];
then
    docker run --rm -it -v "$(pwd)":/home/rust/src ekidd/rust-musl-builder:nightly cargo build --release;
fi;

platform='x86_64-unknown-linux-musl';
out_name='target/'"$platform"'/release/'"$(
    cargo metadata --no-deps --format-version=1 |
        grep -om1 '"name":"[^"]\+"' |
        head -n1 |
        awk -F'"' '{print $(NF - 1)}'
)";
ln -f "$out_name" target/site;
cp -rf templates target;
cp -f Rocket.toml target;

echo 'Build complete.';
);
