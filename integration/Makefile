GOOS = linux
GOARCH = amd64
GOBIN := $(GOPATH)/bin
GODEP := $(GOBIN)/dep
GOLANGCILINT := $(GOBIN)/golangci-lint
GOSEC := $(GOBIN)/gosec
RELEASEDIR ?= ../release/
CIRCLE_PROJECT_REPONAME ?= grace-securityhub
REPO_PATH := github.com/GSA/$(CIRCLE_PROJECT_REPONAME)/integration
APP_PATH := $(REPO_PATH)/vendor/github.com/GSA/grace-app
appenv ?= development
APP_NAME = securityhub
BINARY := $(CIRCLE_PROJECT_REPONAME)-integration

.PHONY: check release lint test clean dependencies
check:
ifeq ($(strip $(TF_VAR_regions)),)
	@echo "TF_VAR_regions must be provided"
	@exit 1
endif

release: lint
	mkdir -p $(RELEASEDIR)
	go test -o $(RELEASEDIR)$(BINARY) -v -ldflags="-X $(APP_PATH).name=$(APP_NAME) -X $(APP_PATH).env=$(appenv) -X $(REPO_PATH).regions=$(TF_VAR_regions)"
	zip -j $(RELEASEDIR)$(BINARY).zip $(RELEASEDIR)$(BINARY)
	rm -f $(RELEASEDIR)$(BINARY)

test: lint
	go test -v -ldflags="-X $(APP_PATH).name=$(APP_NAME) -X $(APP_PATH).env=$(appenv) -X $(REPO_PATH).tenantRole=$(tenant_role) -X $(REPO_PATH).masterRole=$(master_role) -X $(REPO_PATH).regions=$(TF_VAR_regions)"

clean:
	rm -f $(RELEASEDIR)$(BINARY).zip

lint: dependencies Gopkg.toml
	dep ensure
	golangci-lint run ./...
	gosec ./...

Gopkg.toml: $(GODEP)
ifeq (,$(wildcard Gopkg.toml))
	dep init
endif

dependencies: $(GODEP) $(GOLANGCILINT) $(GOSEC)

$(GOLANGCILINT):
	go get -u github.com/golangci/golangci-lint/cmd/golangci-lint

$(GODEP):
	go get -u github.com/golang/dep/cmd/dep

$(GOSEC):
	go get -u github.com/securego/gosec/cmd/gosec