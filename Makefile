ci: test

test: lint
	@crystal spec

lint: bin/ameba
	@bin/ameba

install:
	shards

bin/ameba:
	@make install

