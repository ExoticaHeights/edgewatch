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

# =========================================================
# Release configuration
# =========================================================
REMOTE ?= origin
TAG_NAME ?=

CONFIG_FILE := configs/qemu-aarch64/edgewatch_qemu_aarch64.config
KERNEL_IMAGE := out/buildroot/images/Image
ROOTFS_IMAGE := out/buildroot/images/rootfs.ext4


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
# =========================================================
# Git identity (SELF-CONTAINED, LOCAL + CI)
# =========================================================
git-config:
	@if ! git config user.name >/dev/null; then \
		git config user.name "edgewatch-ci"; \
	fi
	@if ! git config user.email >/dev/null; then \
		git config user.email "edgewatch-ci@users.noreply.github.com"; \
	fi
# =========================================================
# Safety checks
# =========================================================
check-tag-name:
	@test -n "$(TAG_NAME)" || \
	 (echo "ERROR: TAG_NAME not set"; exit 1)

check-clean:
	@git diff --quiet || \
	 (echo "ERROR: working tree not clean"; exit 1)

check-tag-exists:
	@if git rev-parse "$(TAG_NAME)" >/dev/null 2>&1; then \
		echo "ERROR: tag $(TAG_NAME) already exists locally"; \
		exit 1; \
	fi

check-remote-tag:
	@if git ls-remote --tags "$(REMOTE)" | grep -q "refs/tags/$(TAG_NAME)$$"; then \
		echo "ERROR: tag $(TAG_NAME) already exists on remote"; \
		exit 1; \
	fi

check-kernel:
	@test -f "$(KERNEL_IMAGE)" || \
	 (echo "ERROR: Kernel image not found: $(KERNEL_IMAGE)"; exit 1)

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
# =========================================================
# Release (NO COMMITS, RELEASE ONLY)
# =========================================================
release: check-tag-name check-clean git-config check-tag-exists check-remote-tag build check-kernel
	@echo "→ Releasing EdgeWatch $(TAG_NAME)"
	@echo "✔ Using existing committed config: $(CONFIG_FILE)"
	@git tag -a "$(TAG_NAME)" -m "EdgeWatch release $(TAG_NAME)"

push:
	@git push "$(REMOTE)" "$(TAG_NAME)"

gh-release:
	@gh release create "$(TAG_NAME)" \
		--title "$(TAG_NAME)" \
		--notes "EdgeWatch automated release $(TAG_NAME)" \
		"$(KERNEL_IMAGE)" \
		"$(ROOTFS_IMAGE)" \
		|| (echo "ERROR: GitHub release failed"; exit 1)

publish: release push gh-release
	@echo "✔ EdgeWatch $(TAG_NAME) published successfully"

