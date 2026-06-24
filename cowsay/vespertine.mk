APP_NAME    := cowsay
BINARY_PATH := cowsay

CLANG_CONFIG ?= $(abspath ../x86_64-vespertine.cfg)

.PHONY: build clean
build:
	clang --config $(CLANG_CONFIG) -o $(BINARY_PATH) cowsay.c

clean:
	rm -f $(BINARY_PATH)

include ../recipes/application.mk
