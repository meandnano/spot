B=$(shell git rev-parse --abbrev-ref HEAD)
BRANCH=$(subst /,-,$(B))
GITREV=$(shell git describe --abbrev=7 --always --tags)
REV=$(GITREV)-$(BRANCH)-$(shell date +%Y%m%d-%H:%M:%S)
PKGS=$(shell go list ./... | grep -v vendor)


build:
	go build -o bin/spt -ldflags "-X main.revision=$(REV) -s -w" -o ./bin/spt.$(BRANCH)

release:
	- @mkdir -p bin
	docker build -f Dockerfile.release --progress=plain -t spt.bin .
	- @docker rm -f spt.bin 2>/dev/null || exit 0
	docker run -d --name=spt.bin spt.bin
	docker cp spt.bin:/artifacts bin/
	docker rm -f spt.bin

test:
	go clean -testcache
	go test ./...

.PHONY: build release test