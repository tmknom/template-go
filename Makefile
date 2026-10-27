# Include: minimum
-include .makefiles/minimum/Makefile
.makefiles/minimum/Makefile:
	@git clone https://github.com/tmknom/makefiles.git .makefiles >/dev/null 2>&1

# Variables: Go
REPO_ORIGIN ?= $(shell \git config --get remote.origin.url)
REPO_NAME = $(shell \basename -s .git $(REPO_ORIGIN))
VERSION = $(shell \git describe --tags --always --dirty)
COMMIT = $(shell \git rev-parse --short HEAD)
LDFLAGS ?= "-X main.version=$(VERSION) -X main.commit=$(COMMIT)"

# Targets: Go
.PHONY: all
all: mod build test-all run ## all

.PHONY: mod
mod: ## manage modules
	go mod tidy
	go mod verify

.PHONY: deps
deps:
	go mod download

.PHONY: build
build: deps ## build executable binary
	go build -ldflags=$(LDFLAGS) -o bin/$(REPO_NAME) .

.PHONY: install
install: deps ## install
	go install -ldflags=$(LDFLAGS) .

.PHONY: run
run: build ## run command
	bin/$(REPO_NAME) --help

.PHONY: test
test: lint ## test
	go test ./...

.PHONY: lint
lint: goimports vet ## lint go

.PHONY: vet
vet: ## static analysis by vet
	go vet ./...

.PHONY: goimports
goimports: ## update import lines
	goimports -w .

.PHONY: install-tools
install-tools: ## install tools for development
	go install golang.org/x/tools/cmd/goimports@latest

# Targets: GitHub Actions
.PHONY: lint-gha
lint-gha: lint/workflow lint/yaml ## Lint workflow files and YAML files

.PHONY: fmt-gha
fmt-gha: fmt/yaml ## Format YAML files

# Targets: Release
.PHONY: release
release: release/run ## Start release process
