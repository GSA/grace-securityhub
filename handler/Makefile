GOBIN := $(GOPATH)/bin
GOLANGCILINT := $(GOBIN)/golangci-lint
RELEASEDIR ?= ../release/
CIRCLE_PROJECT_REPONAME ?= grace-securityhub
APPNAME := $(CIRCLE_PROJECT_REPONAME)

.PHONY: release clean test lint dependencies
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

dependencies: $(GOLANGCILINT) go.sum

$(GOLANGCILINT):
	go get -u github.com/golangci/golangci-lint/cmd/golangci-lint

go.sum: go.mod
	go mod tidy

go.mod:
	go mod init