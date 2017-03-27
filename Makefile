#===============================================================================
# vim: softtabstop=2 shiftwidth=2 noexpandtab fenc=utf-8 spelllang=en nolist
#===============================================================================

MAKEFLAGS += --warn-undefined-variables -j 8
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail

packer_templates = $(wildcard *.json)
packer_base = $(PACKER_BASE)

# TODO...
# load: import generated boxes into vagrant
# test: run serverspec tests
# assure: run tests against all the boxes
# push: push generated boxes to atlas

all: build 

build: $(packer_templates)
	@packer build $(patsubst %,%;,$^)

clean:
	rm -fv $(packer_base)/box/**/*.box
	rm -rfv $(packer_base)/output/*

PHONY: build clean
