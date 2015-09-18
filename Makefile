.PHONY: deploy

host = awesomnia.awesomeretro.org

Puppetfile.lock: Puppetfile
	librarian-puppet install

apply deploy: Puppetfile.lock
	scripts/deploy.sh ${host}

check: Puppetfile.lock
	scripts/deploy.sh ${host} --noop
