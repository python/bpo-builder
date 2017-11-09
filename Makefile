
# Default username for docker registry
USERNAME ?= python

all:
	docker build -t $(USERNAME)/bpo-builder image
.PHONY: all
