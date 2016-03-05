.PHONY: deploy

host = awesomnia.awesomeretro.org

Puppetfile.lock: Puppetfile
	librarian-puppet install

apply deploy: Puppetfile.lock
	scripts/deploy.sh ${host}

plan: Puppetfile.lock
	scripts/deploy.sh ${host} --noop

.bootstrap.done:
	wget http://apt.puppetlabs.com/puppetlabs-release-pc1-wheezy.deb
	sudo dpkg -i puppetlabs-release-pc1-wheezy.deb
	sudo apt-get update
	sudo apt-get -yqq install puppet librarian-puppet
	sudo gem install hiera-eyaml deep_merge
	touch $@

mrproper clean:
	rm -rf vendor Puppetfile.lock
