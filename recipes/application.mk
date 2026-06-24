# Shared packaging rules for launchable Vespertine port applications.

ifndef APP_NAME
$(error APP_NAME must be set before including ../recipes/application.mk)
endif

ifndef BINARY_PATH
$(error BINARY_PATH must be set before including ../recipes/application.mk)
endif

ASSETS_ROOT  ?= $(abspath ../assets/disk)
PROGRAMS_DIR := $(ASSETS_ROOT)/Programs
BUNDLE_NAME  ?= $(APP_NAME)
BINARY_NAME  ?= $(APP_NAME)
MANIFEST     ?= manifest.toml
BUNDLE_DIR   := $(PROGRAMS_DIR)/$(BUNDLE_NAME).app

.PHONY: all package
all: package

package: build $(MANIFEST)
	echo "[INFO] Packaging $(APP_NAME) as $(BUNDLE_NAME).app"
	test -f $(BINARY_PATH)
	mkdir -p $(BUNDLE_DIR)/bin
	cp $(BINARY_PATH) $(BUNDLE_DIR)/bin/$(BINARY_NAME)
	chmod 0755 $(BUNDLE_DIR)/bin/$(BINARY_NAME)
	cp $(MANIFEST) $(BUNDLE_DIR)/manifest.toml
	# Remove the pre-bundle installation path if an older build left it behind.
	rm -f $(PROGRAMS_DIR)/$(BINARY_NAME)
