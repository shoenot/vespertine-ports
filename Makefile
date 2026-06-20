# Nuke built-in rules and variables.
MAKEFLAGS += -rR --silent
.SUFFIXES:

# --- SUBMODULE CONFIGURATION ---
# Add any new submodule folder names here (space-separated) to automatically pull them
TRACKED_SUBMODULES := mlibc zlib

PREFIX       := $(abspath ../target/build_deps/disk/System)
PROGRAMS_DIR := $(abspath ../target/build_deps/disk/Programs)
CLANG_CONFIG := $(abspath x86_64-vespertine.cfg)

.PHONY: all
all: update-mlibc mlibc ports

.PHONY: update-mlibc
update-mlibc:
	echo "[INFO] Syncing and updating mlibc..."
	git submodule update --init --recursive
	if [ -d "mlibc" ]; then \
		echo "[INFO] Updating submodule tracking for: mlibc"; \
		git submodule update --remote --merge "mlibc"; \
	fi \

.PHONY: mlibc
mlibc: mlibc/build/build.ninja
	echo "[INFO] Building mlibc"
	ninja -C mlibc/build
	echo "[INFO] Installing mlibc"
	DESTDIR=$(abspath ../target/build_deps/disk) ninja -C mlibc/build install

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

.PHONY: ports
ports: cowsay kilo wc ls grep

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

.PHONY: grep
grep: zlib
	echo "[INFO] Building port: grep"
	mkdir -p $(PROGRAMS_DIR)
	$(MAKE) -C grep \
		CC='clang --config $(CLANG_CONFIG)'
	cp grep/grep $(PROGRAMS_DIR)/grep

.PHONY: ls
ls:
	echo "[INFO] Building port: ls"
	mkdir -p $(PROGRAMS_DIR)
	$(MAKE) -C ls \
		CC='clang --config $(CLANG_CONFIG)'
	cp ls/ls $(PROGRAMS_DIR)/ls

.PHONY: wc
wc:
	echo "[INFO] Building port: wc"
	clang --config $(abspath x86_64-vespertine.cfg) -o $(PROGRAMS_DIR)/wc wc/wc.c

.PHONY: cowsay
cowsay:
	echo "[INFO] Building port: cowsay"
	mkdir -p $(PROGRAMS_DIR)
	clang --config $(abspath x86_64-vespertine.cfg) -o $(PROGRAMS_DIR)/cowsay cowsay/cowsay.c

.PHONY: kilo
kilo:
	echo "[INFO] Building port: kilo"
	mkdir -p $(PROGRAMS_DIR)
	clang --config $(abspath x86_64-vespertine.cfg) -o $(PROGRAMS_DIR)/kilo kilo/kilo.c

.PHONY: clean
clean:
	rm -rf mlibc/build

