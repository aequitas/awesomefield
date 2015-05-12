#!/usr/bin/env bash

host=$1
shift

rsync -ai --delete --exclude=.git . ${host}:provision/;ssh ${host} sudo provision/scripts/apply.sh $*
