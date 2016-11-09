#===============================================================================
# vim: softtabstop=2 shiftwidth=2 noexpandtab fenc=utf-8 spelllang=en nolist
#===============================================================================

# Automatic Variables
# -------------------
# $@ – the target filename
# $< – the filename of the first prerequisite
# $? – space-delimited list of all prerequisites

MAKEFLAGS += --warn-undefined-variables -j 8
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail

packer_templates = docker_ubuntu1604.json
#packer_templates = $(wildcard *.json)
packer_base = $(PACKER_BASE)
vagrant_boxes = $(packer_base)/box/*/*.box

# TODO...
# setup: create the necessary directories and install vagrant plugins
# load: import generated boxes into vagrant
# test: run serverspec tests
# assure: run tests against all the boxes
# push: push generated boxes to atlas
# clean: clean up build detritus
# ssh: ubuntu1604 virtualbox

all: build 

setup:
	@vagrant plugin install vagrant-serverspec

build: $(packer_templates)
	@packer build $(patsubst %,%;,$^)

load: $(vagrant_boxes)
	@echo $^

clean:
	rm -fv $(packer_base)/box/**/*.box
	rm -rfv $(packer_base)/output/*

PHONY: build clean load setup
