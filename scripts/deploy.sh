#!/usr/bin/env bash

host=$1
shift

sync='hiera keys manifests modules scripts hiera.yaml vendor'

rsync -a --delete ${sync} ${host}:provision/ && \
    ssh ${host} sudo provision/scripts/apply.sh $*
