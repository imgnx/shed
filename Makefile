.PHONY: test lint install fmt ci

test:
	bash tests/run.sh

lint:
	@command -v shellcheck >/dev/null 2>&1 && shellcheck -x bin/shed contrib/zsh/focus-burst.zsh || echo "shellcheck not found; skipping"

install:
	bash install.sh

fmt:
	@printf "Nothing to format; shell scripts only.\n"

ci: lint test

