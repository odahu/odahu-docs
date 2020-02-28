SHELL := /bin/bash

-include .env
.DEFAULT_GOAL := help

## build-docs: Build legion docs
build-docs: build-docs-builder
	docker run --rm -v $(PWD):/var/docs --workdir /var/docs odahu/docs-builder:latest /generate.sh

## build-docs-builder: Build docker image that can build documentation
build-docs-builder:
	docker build -t odahu/docs-builder:latest -f Dockerfile .

## install-vulnerabilities-checker: Install the vulnerabilities-checker
install-vulnerabilities-checker:
	./scripts/install-git-secrets-hook.sh install_binaries

## check-vulnerabilities: Сheck vulnerabilities in the source code
check-vulnerabilities:
	./scripts/install-git-secrets-hook.sh install_hooks
	git secrets --scan -r

## check-broken-urls: Сheck broken urls in documentation
check-broken-urls:
	python ./scripts/links_linter.py source md rst --verbose

## help: Show the help message
help: Makefile
	@echo "Choose a command run in "$(PROJECTNAME)":"
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sort | sed -e 's/\\$$//' | sed -e 's/##//'
	@echo
