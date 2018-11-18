#!/usr/bin/env sh
set -eu;
useradd -u1000 rocket
chown rocket:rocket /web;
su rocket -c /web/site;
