#!/usr/bin/env bash
set -eu;

cd "$(
    readlink -f "$(
        dirname "$(
            readlink -f "$0";
        )";
    )";
)";

function run_if_empty()
{
    local container_name="$1";
    shift;
    local docker_run=("$@");

    if [[ -z "$(docker ps --all --format '{{.Names}}' --filter 'name='"$container_name")" ]];
    then
        "${docker_run[@]}";
    fi;
}

basename="$(basename "$(pwd)")"'_';
cd ..;
pwd="$(pwd)";
volume_name="$basename"'database';
network_name="$basename"'default';

#version: "3.7"
#services:
    run_db=(
        docker run
        '--name' "$basename"'db'
        '--network='"$network_name"
        '--network-alias=db'
        '--detach=true'
        '--restart=always'
        #volumes:
            '--mount'
            'type=volume,volume-driver=local,src='"$volume_name"',dst=/var/lib/postgresql/data'
        #expose:
            '--expose=5432'
        #ports:
            '-p5432:5432'
        #environment:
            '--env' 'POSTGRES_USER=docker'
            '--env' 'POSTGRES_PASSWORD=docker'
        #image:
            'postgres:alpine'
    );
    run_rocket=(
        docker run
        '--interactive=true'
        '--name' "$basename"'rocket'
        '--network='"$network_name"
        '--network-alias=rocket'
        '--detach=true'
        '--restart=always'
        #volumes:
            '--mount'
            'type=bind,source='"$pwd"'/target,target=/web'
            '--mount'
            'type=bind,source='"$pwd"'/docker/entrypoints/rocket.sh,target=/entrypoint'
        #logging:
            '--log-driver=journald'
        #expose:
            '--expose=8000'
        #image:
            'alpine:edge'
        #command:
            '/entrypoint'
    );
    run_web=(
        docker run
        '--interactive=true'
        '--name' "$basename"'web'
        '--network='"$network_name"
        '--network-alias=web'
        '--detach=true'
        '--restart=always'
        #volumes:
            '--mount'
            'type=bind,source='"$pwd"'/docker/nginx,target=/etc/nginx'
            '--mount'
            'type=bind,source='"$pwd"'/public,target=/web'
            '--mount'
            'type=bind,source='"$pwd"'/docker/entrypoints/web.sh,target=/entrypoint'
        #logging:
            '--log-driver=journald'
        #ports:
            '-p80:80'
            '-p443:443'
        #image:
            'nginx:alpine'
        #command:
            '/entrypoint'
    );
#volumes:
    #database:
        volume=(
            'docker' 'volume' 'create'
        #driver:
            '--driver'
            'local'
            "$volume_name"
        );
#networks:
    #default:
        network=(
        'docker' 'network' 'create' '-d' 'bridge' '--subnet=192.168.0.0/16'
        #driver_opts:
            '--opt' 'com.docker.network.bridge.host_binding_ipv4=127.0.0.1'
            '--opt' 'com.docker.network.mtu=1400'
        "$network_name"
        );

if [[ -z "$(docker volume ls --format '{{.Name}}' --filter 'name='"$volume_name")" ]];
then
    "${volume[@]}";
fi;

if [[ -z "$(docker network ls --format '{{.Name}}' --filter 'name='"$network_name")" ]];
then
    "${network[@]}";
fi;

run_if_empty "$basename"'db' "${run_db[@]}";
run_if_empty "$basename"'rocket' "${run_rocket[@]}";
run_if_empty "$basename"'web' "${run_web[@]}";
