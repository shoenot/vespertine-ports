# Nuke built-in rules and variables.
MAKEFLAGS += -rR --silent
.SUFFIXES:

# --- SUBMODULE CONFIGURATION ---
# Add any new submodule folder names here (space-separated) to automatically pull them
TRACKED_SUBMODULES := mlibc zlib

ASSETS_ROOT  := $(abspath ../assets/disk)
PREFIX       := $(ASSETS_ROOT)/System
CLANG_CONFIG := $(abspath x86_64-vespertine.cfg)

# A launchable port opts into application packaging by providing a
# vespertine.mk file. Upstream Makefiles and GNUmakefiles remain untouched.
PORT_APPS := $(sort $(patsubst %/vespertine.mk,%,$(wildcard */vespertine.mk)))
PORT_PACKAGES := $(addprefix package-,$(PORT_APPS))

.PHONY: all
all: ports

.PHONY: update-mlibc
update-mlibc:
	echo "[INFO] Syncing and updating mlibc..."
	git submodule update --init --recursive
	if [ -d "mlibc" ]; then \
		echo "[INFO] Updating submodule tracking for: mlibc"; \
		git submodule update --remote --merge "mlibc"; \
	fi \

.PHONY: mlibc
mlibc: update-mlibc mlibc/build/build.ninja
	echo "[INFO] Building mlibc"
	ninja -C mlibc/build
	echo "[INFO] Installing mlibc"
	DESTDIR=$(ASSETS_ROOT) ninja -C mlibc/build install

mlibc/build/build.ninja: mlibc/meson.build
	echo "[INFO] Configuring mlibc"
	mkdir -p mlibc/build
	meson setup mlibc/build mlibc \
		--cross-file $(abspath cross.ini) \
		--prefix=/System \
		--includedir=Headers \
		--libdir=Libraries \
		-Dlibgcc_dependency=false \
		-Ddefault_library=shared

# Target relies on the submodule directory existing via 'update-submodules'
mlibc/meson.build:
	@if [ ! -f mlibc/meson.build ]; then \
		echo "[ERROR] mlibc source files are missing. Ensure submodules are initialized."; \
		exit 1; \
	fi

.PHONY: ports $(PORT_PACKAGES)
ports: mlibc $(PORT_PACKAGES)

$(PORT_PACKAGES): mlibc

$(PORT_PACKAGES): package-%:
	echo "[INFO] Packaging port application: $*"
	$(MAKE) -C $* -f vespertine.mk package \
		ASSETS_ROOT='$(ASSETS_ROOT)' \
		CLANG_CONFIG='$(CLANG_CONFIG)'

.PHONY: zlib
zlib:
	echo "[INFO] Building port: zlib"
	$(MAKE) -C zlib -f ../recipes/zlib.mk \
		CC='clang --config $(CLANG_CONFIG)' \
		AR=llvm-ar \
		RANLIB=llvm-ranlib
	mkdir -p $(PREFIX)/Libraries
	mkdir -p $(PREFIX)/Headers
	cp zlib/libz.a $(PREFIX)/Libraries/libz.a
	cp zlib/zlib.h $(PREFIX)/Headers/zlib.h
	cp zlib/zconf.h $(PREFIX)/Headers/zconf.h

# grep links against the separately installed zlib system library.
package-grep: zlib

.PHONY: clean
clean:
	rm -rf mlibc/build
	for app in $(PORT_APPS); do \
		$(MAKE) -C $$app -f vespertine.mk clean || exit 1; \
	done
	if [ -d zlib ]; then \
		$(MAKE) -C zlib -f ../recipes/zlib.mk clean; \
	fi
