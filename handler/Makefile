GOBIN := $(GOPATH)/bin
GOLANGCILINT := $(GOBIN)/golangci-lint
GOSEC := $(GOBIN)/gosec
RELEASEDIR ?= ../release/
CIRCLE_PROJECT_REPONAME ?= grace-securityhub
APPNAME := $(CIRCLE_PROJECT_REPONAME)

.PHONY: precommit release clean test lint dependencies
release: test
	mkdir -p $(RELEASEDIR)
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(RELEASEDIR)$(APPNAME) -v
	zip -j $(RELEASEDIR)$(APPNAME).zip $(RELEASEDIR)$(APPNAME)
	rm -f $(RELEASEDIR)$(APPNAME)

clean:
	rm -f $(RELEASEDIR)$(APPNAME).zip

test: lint
	go test -v ./...

lint: dependencies
	golangci-lint run ./...
	gosec ./...

dependencies: $(GOLANGCILINT) $(GOSEC) go.sum precommit

$(GOLANGCILINT):
	go get github.com/golangci/golangci-lint/cmd/golangci-lint@v1.41.1

$(GOSEC):
	go get github.com/securego/gosec/v2/cmd/gosec@v2.8.1

go.sum: go.mod
	go mod tidy

go.mod:
	go mod init

precommit:
ifneq ($(strip $(hooksPath)),.github/hooks)
	@git config --add core.hooksPath .github/hooks
endif
