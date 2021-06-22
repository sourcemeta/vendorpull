.PHONY: lint test

# The current git commit hash
GIT_REVISION = $(shell git rev-parse HEAD)

lint:
	shellcheck *.sh vendorpull test/*.sh

test:
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/bootstrap-pristine.sh
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/patch.sh
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/mask.sh
