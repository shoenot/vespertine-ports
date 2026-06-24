APP_NAME    := ls
BINARY_PATH := ls

CLANG_CONFIG ?= $(abspath ../x86_64-vespertine.cfg)

.PHONY: build clean
build:
	$(MAKE) -f GNUmakefile \
		CC='clang --config $(CLANG_CONFIG)'

clean:
	$(MAKE) -f GNUmakefile clean

include ../recipes/application.mk
