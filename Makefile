.PHONY: deploy

host = awesomnia.awesomeretro.org

Puppetfile.lock: Puppetfile
	librarian-puppet install

apply deploy: Puppetfile.lock
	scripts/deploy.sh ${host}

plan: Puppetfile.lock
	scripts/deploy.sh ${host} --noop
