GOBIN := $(GOPATH)/bin
GODEP := $(GOBIN)/dep
GOSEC := $(GOBIN)/gosec
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

lint: Gopkg.toml dependencies
	dep ensure
	golangci-lint run ./...
	gosec ./...

Gopkg.toml:
ifeq (,$(wildcard Gopkg.toml))
	dep init
endif

dependencies: $(GODEP) $(GOSEC) $(GOMETALINTER)

$(GOLANGCILINT):
	go get -u github.com/golangci/golangci-lint/cmd/golangci-lint

$(GODEP):
	go get -u github.com/golang/dep/cmd/dep

$(GOSEC):
	go get -u github.com/securego/gosec/cmd/gosec