#!/usr/bin/env sh
set -eu;
adduser -Du1000 rocket;
chown rocket:rocket /web;
cd /web;
su rocket -c ./site;
