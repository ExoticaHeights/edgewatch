# EdgeWatch top-level Makefile
# Reproducible Buildroot build wrapper

BUILDROOT_DIR := buildroot
OUT_DIR       := out/buildroot

TOOLCHAIN_DIR := toolchains
TOOLCHAIN_NAME := arm-gnu-toolchain-13.2.rel1-x86_64-aarch64-none-linux-gnu
TOOLCHAIN_TARBALL := $(TOOLCHAIN_NAME).tar.xz

TOOLCHAIN_RELEASE := toolchain-v1.0.0
TOOLCHAIN_URL := https://github.com/ExoticaHeights/edgewatch/releases/download/$(TOOLCHAIN_RELEASE)/$(TOOLCHAIN_TARBALL)

TOOLCHAIN_PATH := $(TOOLCHAIN_DIR)/$(TOOLCHAIN_NAME)

CONFIG_FILE := configs/qemu-aarch64/edgewatch_qemu_aarch64.config

.PHONY: all help toolchain build clean distclean

all: build

help:
	@echo "EdgeWatch Build System"
	@echo ""
	@echo "Targets:"
	@echo "  toolchain   Download and extract external ARM GNU toolchain"
	@echo "  build       Apply config and build Buildroot (depends on toolchain)"
	@echo "  clean       Clean build artifacts"
	@echo "  distclean   Remove all build output"
	@echo ""

toolchain:
	@echo "==> Preparing external toolchain"
	@if [ -x "$(TOOLCHAIN_PATH)/bin/aarch64-none-linux-gnu-gcc" ]; then \
		echo "Toolchain already present: $(TOOLCHAIN_PATH)"; \
	else \
		mkdir -p $(TOOLCHAIN_DIR); \
		echo "Downloading toolchain..."; \
		curl -L --fail -o $(TOOLCHAIN_DIR)/$(TOOLCHAIN_TARBALL) $(TOOLCHAIN_URL); \
		echo "Extracting toolchain..."; \
		tar -xf $(TOOLCHAIN_DIR)/$(TOOLCHAIN_TARBALL) -C $(TOOLCHAIN_DIR); \
		rm -f $(TOOLCHAIN_DIR)/$(TOOLCHAIN_TARBALL); \
	fi

build: toolchain
	@echo "==> Preparing build directory"
	mkdir -p $(OUT_DIR)

	@echo "==> Applying EdgeWatch QEMU AArch64 config"
	cp $(CONFIG_FILE) $(OUT_DIR)/.config

	@echo "==> Building Buildroot"
	$(MAKE) -C $(BUILDROOT_DIR) O=$(abspath $(OUT_DIR))

clean:
	@echo "==> Cleaning build artifacts"
	$(MAKE) -C $(BUILDROOT_DIR) O=$(abspath $(OUT_DIR)) clean

distclean:
	@echo "==> Removing all build output"
	rm -rf out

