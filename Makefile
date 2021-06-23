.PHONY: build lint test
.DEFAULT_GOAL = build

# The current git commit hash
GIT_REVISION = $(shell git rev-parse HEAD)

HEADERS = include/assert.sh \
					include/masker.sh \
					include/patcher.sh \
					include/tmpdir.sh \
					include/vcs/git.sh

%: src/%.sh $(HEADERS)
	gpp -o $@ -I include \
		-U "" "" "(" "," ")" "(" ")" "\#" "\\" \
		-M "%" "\n" " " " " "\n" "(" ")" \
		$<
	chmod +x $@

build: vendorpull bootstrap

lint:
	shellcheck bootstrap vendorpull test/*.sh

test:
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/bootstrap-pristine.sh
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/patch.sh
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/mask.sh
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/help.sh
