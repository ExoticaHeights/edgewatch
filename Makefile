# =========================================================
# EdgeWatch BSP – Makefile (Makefile-Owned Release Flow)
# =========================================================

# ---------------------------------------------------------
# Paths
# ---------------------------------------------------------
BUILDROOT_SRC_RAW := buildroot
BUILD_DIR_RAW     := build

BUILDROOT_SRC := $(abspath $(strip $(BUILDROOT_SRC_RAW)))
BUILD_DIR     := $(abspath $(strip $(BUILD_DIR_RAW)))

CONFIG_DIR    := configs
PATCH_DIR     := patches
CONFIG_FILE   := $(CONFIG_DIR)/edgewatch_defconfig

KERNEL_IMAGE  := $(BUILD_DIR)/output/images/Image
TOOLCHAIN_IMAGE := EdgeWatch.tar.gz

# ---------------------------------------------------------
# External Toolchain (MANDATORY)
# ---------------------------------------------------------
TOOLCHAIN_VERSION ?= toolchain-v1.0.0
TOOLCHAIN_NAME := arm-gnu-toolchain-13.2.Rel1-x86_64-aarch64-none-linux-gnu
TOOLCHAIN_ARCHIVE := $(TOOLCHAIN_NAME).tar.xz

TOOLCHAIN_DIR := toolchains/$(TOOLCHAIN_NAME)
TOOLCHAIN_BIN := $(TOOLCHAIN_DIR)/bin/aarch64-none-linux-gnu-gcc

TOOLCHAIN_REPO := ExoticaHeights/edgewatch
TOOLCHAIN_URL := https://github.com/$(TOOLCHAIN_REPO)/releases/download/$(TOOLCHAIN_VERSION)/$(TOOLCHAIN_ARCHIVE)


REMOTE        := origin

# ---------------------------------------------------------
# Buildroot
# ---------------------------------------------------------
DEFCONFIG := qemu_aarch64_virt_defconfig

# ---------------------------------------------------------
# Versioning (Makefile owns this)
# ---------------------------------------------------------
VERSION ?=
TAG_PREFIX := edgewatch-bsp-v
TAG_NAME   := $(TAG_PREFIX)$(VERSION)

# ---------------------------------------------------------
# Phony
# ---------------------------------------------------------
.PHONY: help prepare defconfig menuconfig patches build \
        sync-config git-config \
        check-version check-clean check-tag-exists check-remote-tag check-kernel \
        release push gh-release publish toolchain

# =========================================================
# Help
# =========================================================
help:
	@echo "EdgeWatch BSP – Makefile-driven release"
	@echo ""
	@echo "Usage:"
	@echo "  make publish VERSION=x.y.z"
	@echo ""
	@echo "Targets:"
	@echo "  defconfig     Configure Buildroot"
	@echo "  build         Build BSP"
	@echo "  publish       Build + tag + release"

# =========================================================
# Toolchain fetch & install
# =========================================================
toolchain:
	@echo "→ Preparing external toolchain $(TOOLCHAIN_VERSION)"
	@mkdir -p toolchains
	@if [ ! -f "$(TOOLCHAIN_ARCHIVE)" ]; then \
		echo "Downloading $(TOOLCHAIN_ARCHIVE)"; \
		curl -L -o "$(TOOLCHAIN_ARCHIVE)" "$(TOOLCHAIN_URL)"; \
	fi
	@if [ ! -d "$(TOOLCHAIN_DIR)" ]; then \
		echo "Extracting toolchain"; \
		tar -xf "$(TOOLCHAIN_ARCHIVE)" -C toolchains; \
	fi
	@test -x "$(TOOLCHAIN_BIN)" || \
	 (echo "ERROR: toolchain gcc not found"; exit 1)
	@echo "✔ Toolchain ready: $(TOOLCHAIN_BIN)"


# =========================================================
# Prepare build directory
# =========================================================
prepare:
	@echo "BUILDROOT_SRC = $(BUILDROOT_SRC)"
	@echo "BUILD_DIR     = $(BUILD_DIR)"
	@test -d "$(BUILDROOT_SRC)" || (echo "ERROR: buildroot missing"; exit 1)
	@mkdir -p "$(BUILD_DIR)"
	@if [ ! -f "$(BUILD_DIR)/Makefile" ]; then \
		echo "→ Copying Buildroot source"; \
		rsync -a --delete --exclude '.git' "$(BUILDROOT_SRC)/" "$(BUILD_DIR)/"; \
	fi

# =========================================================
# Configuration
# =========================================================
defconfig: prepare
	$(MAKE) -C "$(BUILD_DIR)" $(DEFCONFIG)
	@$(MAKE) sync-config

menuconfig: prepare
	$(MAKE) -C "$(BUILD_DIR)" menuconfig
	@$(MAKE) sync-config

# =========================================================
# Apply patches (kept from your logic)
# =========================================================
patches: prepare
	@if [ -d "$(PATCH_DIR)" ]; then \
		echo "→ Applying patches"; \
		cp -R "$(PATCH_DIR)/"* "$(BUILD_DIR)/" || true; \
	fi

# =========================================================
# Build
# =========================================================
build: prepare patches toolchain
	@test -f "$(CONFIG_FILE)" || (echo "ERROR: config missing"; exit 1)
	cp "$(CONFIG_FILE)" "$(BUILD_DIR)/.config"
	$(MAKE) -C "$(BUILD_DIR)" olddefconfig
	$(MAKE) -C "$(BUILD_DIR)" -j$(shell nproc)
	@ls "$(BUILD_DIR)/output/images" >/dev/null

# =========================================================
# Sync config back to repo
# =========================================================
sync-config:
	@mkdir -p "$(CONFIG_DIR)"
	@cp "$(BUILD_DIR)/.config" "$(CONFIG_FILE)"

# =========================================================
# Git identity (CI-safe)
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
check-version:
	@test -n "$(VERSION)" || \
	 (echo "ERROR: VERSION not set. Use: make publish VERSION=x.y.z"; exit 1)

check-clean:
	@git diff --quiet || (echo "ERROR: working tree not clean"; exit 1)

check-tag-exists:
	@if git rev-parse "$(TAG_NAME)" >/dev/null 2>&1; then \
		echo "ERROR: tag $(TAG_NAME) already exists locally"; exit 1; \
	fi

check-remote-tag:
	@if git ls-remote --tags "$(REMOTE)" | grep -q "refs/tags/$(TAG_NAME)$$"; then \
		echo "ERROR: tag $(TAG_NAME) already exists on remote"; exit 1; \
	fi

check-kernel:
	@test -f "$(KERNEL_IMAGE)" || \
	 (echo "ERROR: Kernel image not found"; exit 1)

# =========================================================
# Release
# =========================================================
release: check-version check-clean git-config check-tag-exists check-remote-tag defconfig build check-kernel
	@echo "→ Releasing $(TAG_NAME)"
	@git tag -a "$(TAG_NAME)" -m "EdgeWatch BSP $(TAG_NAME)"

# =========================================================
# Push + GitHub release
# =========================================================
push:
	@git push "$(REMOTE)" "$(TAG_NAME)"

gh-release:
	@gh release create "$(TAG_NAME)" \
		--title "$(TAG_NAME)" \
		--notes "EdgeWatch BSP release $(TAG_NAME)" \
		"$(CONFIG_FILE)" \
		"$(KERNEL_IMAGE)" \
		|| (echo "ERROR: GitHub release failed"; exit 1)

publish: release push gh-release
	@echo "✔ BSP $(TAG_NAME) published successfully"
