.PHONY: build lint test clean
.DEFAULT_GOAL = build

# The current git commit hash
GIT_REVISION = $(shell git rev-parse HEAD)

HEADERS = include/assert.sh \
					include/masker.sh \
					include/patcher.sh \
					include/tmpdir.sh \
					include/vcs/git.sh

COMMANDS = bootstrap \
					 pull

%: src/%.sh $(HEADERS)
	gpp -o $@ -I include \
		-U "" "" "(" "," ")" "(" ")" "\#" "\\" \
		-M "%" "\n" " " " " "\n" "(" ")" \
		$<
	chmod +x $@

build: $(COMMANDS)

lint: $(COMMANDS)
	shellcheck $(COMMANDS) test/*.sh

test:
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/bootstrap-pristine.sh
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/patch.sh
	VENDORPULL_REVISION=$(GIT_REVISION) ./test/mask.sh

clean:
	rm $(COMMANDS)
