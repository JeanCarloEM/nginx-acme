#!/usr/bin/env sh

alias openssl="openssl3"

trap "echo stop && killall crond && exit 0" SIGTERM SIGINT
crond && while true; do sleep 1; done;