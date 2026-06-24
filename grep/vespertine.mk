APP_NAME    := grep
BINARY_PATH := grep

CLANG_CONFIG ?= $(abspath ../x86_64-vespertine.cfg)

.PHONY: build clean
build:
	$(MAKE) -f Makefile \
		CC='clang --config $(CLANG_CONFIG)'

clean:
	$(MAKE) -f Makefile clean

include ../recipes/application.mk
