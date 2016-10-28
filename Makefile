#===============================================================================
# vim: softtabstop=2 shiftwidth=2 noexpandtab fenc=utf-8 spelllang=en nolist
#===============================================================================
# Cheat Sheet - http://www.cheatography.com/bavo-van-achte/cheat-sheets/gnumake/
# Refcard - http://www.schacherer.de/frank/technology/tools/make.html

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
packer_base = /Volumes/FLASH_DRIVE/packer
vagrant_boxes = $(packer_base)/box/*/*.box

# setup: create the necessary directories and install vagrant plugins
# load: import generated boxes into vagrant
# test: run serverspec tests
# assure: run tests against all the boxes
# push: push generated boxes to atlas
# clean: clean up build detritus
# ssh: ubuntu1604 virtualbox

#deliver:
	#@for box_name in $(BOX_NAMES) ; do \
		#echo Uploading $$box_name to Atlas ; \
		#bin/register_atlas.sh $$box_name $(BOX_SUFFIX) $(BOX_VERSION) ; \
	#done

#load: $(vagrant_boxes)
	#@$(patsubst %,echo %;,$^)

#load: $(vagrant_boxes)
	#echo $(patsubst %,%;,$^)

all: build 

setup:
	@vagrant plugin install vagrant-serverspec

build: $(packer_templates)
	@packer build $(patsubst %,%;,$^)

load: $(vagrant_boxes)
	@echo $^

clean:
	rm -fv $(packer_base)/box/**/*.box

PHONY: build clean load setup
