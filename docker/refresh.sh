#!/usr/bin/env bash
set -eu;

cd "$(
    readlink -f "$(
        dirname "$(
            readlink -f "$0";
        )";
    )";
)";

./build.sh;

container="$(docker ps --all --quiet --filter 'name=docker_rocket')";

if [[ -n "$container" ]];
then
    docker kill "$container";
    docker rm "$container";
fi;

./run.sh;
