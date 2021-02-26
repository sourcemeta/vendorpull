.PHONY: lint test

lint:
	shellcheck *.sh update test/*.sh

test:
	./test/bootstrap-pristine.sh
