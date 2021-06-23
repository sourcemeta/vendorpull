.PHONY: lint test
.DEFAULT_GOAL = vendorpull

# The current git commit hash
GIT_REVISION = $(shell git rev-parse HEAD)

HEADERS = include/assert.sh \
					include/masker.sh \
					include/patcher.sh \
					include/tmpdir.sh \
					include/vcs/git.sh

vendorpull: src/vendorpull.sh $(HEADERS)
	gpp -o $@ -I include \
		-U "" "" "(" "," ")" "(" ")" "\#" "\\" \
		-M "%" "\n" " " " " "\n" "(" ")" \
		$<
	chmod +x $@

lint:
	shellcheck *.sh vendorpull test/*.sh

test:
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/bootstrap-pristine.sh
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/patch.sh
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/mask.sh
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/help.sh
