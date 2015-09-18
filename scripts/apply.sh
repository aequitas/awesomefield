#!/usr/bin/env bash

cd $(dirname $0)/..

which puppet >/dev/null || ./bootstrap.sh

puppet apply \
  --modulepath=modules:vendor/modules \
  --hiera_config=hiera.yaml \
  manifests/site.pp $*
