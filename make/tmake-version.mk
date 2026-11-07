# this file is a part of tmake, get the latest version at https://github.com/stanix-org/tconf
# makefile include to get version

VERSION := $(shell git describe --tags --always 2>/dev/null || echo unknown)
CFLAGS += -DVERSION='"$(VERSION)"'
