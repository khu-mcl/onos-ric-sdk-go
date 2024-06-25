# SPDX-FileCopyrightText: 2020-present Open Networking Foundation <info@opennetworking.org>
#
# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 Kyunghee University

export CGO_ENABLED=1
export GO111MODULE=on

.PHONY: build

TARGET := onos-ric-sdk-go
ONOS_PROTOC_VERSION := v0.6.3


build-tools:=$(shell if [ ! -d "./build/build-tools" ]; then cd build && git clone https://github.com/onosproject/build-tools.git; fi)
include ./build/build-tools/make/onf-common.mk

mod-update: # @HELP Download the dependencies to the vendor folder
	go mod tidy
	go mod vendor
mod-lint: mod-update # @HELP ensure that the required dependencies are in place
	# dependencies are vendored, but not committed, go.sum is the only thing we need to check
	bash -c "diff -u <(echo -n) <(git diff go.sum)"

test: # @HELP run the unit tests and source code validation
test: mod-lint linters license
	go test github.com/onosproject/${TARGET}/pkg/...

#jenkins-test:  # @HELP run the unit tests and source code validation producing a junit style report for Jenkins
#jenkins-test: mod-lint linters license
#	TEST_PACKAGES=github.com/onosproject/${TARGET}/pkg/... ./build/build-tools/build/jenkins/make-unit

publish: # @HELP publish version on github and dockerhub
	./build/build-tools/publish-version ${VERSION}

#jenkins-publish: # @HELP Jenkins calls this to publish artifacts
#	./build/build-tools/release-merge-commit

all: test

clean:: # @HELP remove all the build artifacts
	rm -rf ./build/_output ./vendor
