APP_NAME    := kilo
BINARY_PATH := kilo

CLANG_CONFIG ?= $(abspath ../x86_64-vespertine.cfg)

.PHONY: build clean
build:
	clang --config $(CLANG_CONFIG) -o $(BINARY_PATH) kilo.c

clean:
	rm -f $(BINARY_PATH)

include ../recipes/application.mk
