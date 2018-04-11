
# Default username for docker registry
USERNAME ?= python

builder:
	docker build -t $(USERNAME)/bpo-builder builder
.PHONY: builder

all: builder
.PHONY: all
