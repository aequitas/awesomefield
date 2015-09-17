.PHONY: deploy

host = awesomnia.awesomeretro.org

Puppetfile.lock: Puppetfile
	librarian-puppet install

deploy: Puppetfile.lock
	scripts/deploy.sh ${host}

check: Puppetfile.lock
	scripts/deploy.sh ${host} --noop --verbose
