#!/usr/bin/env bash

set -ve

curl http://apt.puppetlabs.com/puppetlabs-release-trusty.deb -o puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get -q update
sudo apt-get install -yqq puppet
sudo gem install hiera-eyaml deep_merge hiera highline
