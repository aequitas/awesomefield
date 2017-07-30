.PHONY: deploy

host = awesomnia.awesomeretro.org

Puppetfile.lock: Puppetfile
	librarian-puppet install
	touch $@

apply deploy: Puppetfile.lock
	scripts/deploy.sh ${host} ${args}

plan: Puppetfile.lock
	scripts/deploy.sh ${host} --noop --test --verbose ${args}

mrproper clean:
	rm -rf vendor Puppetfile.lock
