#!/usr/bin/env sh
set -eu;
adduser -Du1000 web;
chown web:web /web;
nginx -g'daemon off;';
