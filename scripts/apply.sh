#!/usr/bin/env bash

cd $(dirname $0)/..

which puppet || ./bootstrap.sh

puppet apply --verbose --modulepath=modules:vendor/modules --hiera_config=hiera.yaml manifests/site.pp $*