#!/usr/bin/env bash
set -eu;

nobuild='nobuild';
while (( $# > 0 ));
do
    arg="$0";
    shift;
    if [[ "$arg" == '-b' || "$arg" == '--build' ]];
    then
        nobuild='';
        break;
    fi;
done;

cd "$(
    readlink -f "$(
        dirname "$(
            readlink -f "$0";
        )";
    )";
)";

. ./build.sh;

container="$(docker ps --all --quiet --filter 'name=docker_rocket')";

if [[ -n "$container" ]];
then
    docker kill "$container";
    docker rm "$container";
fi;

./run.sh;
