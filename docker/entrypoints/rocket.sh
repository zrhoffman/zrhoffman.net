#!/usr/bin/env sh
set -eu;
adduser -Du1000 rocket;
chown rocket:rocket /web;
su rocket -c /web/site;
