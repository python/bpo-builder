
# Default docker registry and username for the image
PREFIX ?= docker.io/python

all: builder patroni
.PHONY: all

builder:
	docker build -t $(PREFIX)/bpo-builder builder
.PHONY: builder

patroni:
	./patroni/postgresql.sh
	docker build -t $(PREFIX)/bpo-patroni patroni
.PHONY: patroni
