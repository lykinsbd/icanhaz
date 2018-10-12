# The version of the container will be the name of the most recent git tag. Before building a new container,
# please tag the repo with the new version number.
version = $(shell git for-each-ref --sort=-taggerdate --format '%(refname:short)' refs/tags | head -n 1)

.phony: all container

all:
	@echo The current tagged version is $(version)
	@echo Run 'make container' to build a new container and tag it with this version.

container:
	@echo Checking for untagged changes...
	test -z "$(shell git status --porcelain)"
	git diff-index --quiet $(version)
	@echo Repo is clean.
	@echo Building container...
	docker build --pull --build-arg version="$(version)" \
	--tag lykinsbd/icanhaz:$(version) \
	--tag lykinsbd/icanhaz:latest .

push:
	@echo Pushing container...
	docker push lykinsbd/icanhaz:$(version)
	docker push lykinsbd/icanhaz:latest