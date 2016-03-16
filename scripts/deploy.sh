#!/usr/bin/env bash

set -e

host=$1
shift

sync='hiera keys manifests modules scripts hiera.yaml vendor'

rsync -v -a --delete --exclude .git --exclude spec ${sync} ${host}:provision/

ssh ${host} sudo provision/scripts/apply.sh $*
