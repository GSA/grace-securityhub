GOOS = linux
GOARCH = amd64
GOBIN := $(GOPATH)/bin
GOLANGCILINT := $(GOBIN)/golangci-lint
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

lint: dependencies
	golangci-lint run ./...

dependencies: $(GOLANGCILINT) go.sum

$(GOLANGCILINT):
	go get -u github.com/golangci/golangci-lint/cmd/golangci-lint

go.sum: go.mod
	go mod tidy

go.mod:
	go mod init