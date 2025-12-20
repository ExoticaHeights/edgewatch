# =========================================================
# EdgeWatch BSP – Config-only Release Makefile (FINAL)
# =========================================================

# ---------------- Paths (CLEAN) ----------------
BUILDROOT_SRC_RAW := buildroot
BUILD_DIR_RAW     := build

BUILDROOT_SRC := $(abspath $(strip $(BUILDROOT_SRC_RAW)))
BUILD_DIR     := $(abspath $(strip $(BUILD_DIR_RAW)))
JSON_FILE     := $(BUILD_DIR)/buildroot.json
REMOTE        := origin

# ---------------- Buildroot ----------------
DEFCONFIG := qemu_aarch64_virt_defconfig

# ---------------- Versioning (MANDATORY) ----------------
VERSION ?=
ifeq ($(strip $(VERSION)),)
$(error VERSION is not set. Use: make publish VERSION=x.y.z)
endif

TAG_PREFIX := edgewatch-bsp-v
TAG_NAME   := $(TAG_PREFIX)$(VERSION)

# ---------------- Phony ----------------
.PHONY: help prepare defconfig menuconfig build \
        gen-json git-config check-clean \
        check-tag-exists check-remote-tag \
        release push gh-release publish

# =========================================================
# Help
# =========================================================
help:
	@echo "EdgeWatch BSP – config-only release"
	@echo ""
	@echo "Usage:"
	@echo "  make publish VERSION=x.y.z"
	@echo ""
	@echo "Releases ONLY:"
	@echo "  build/.config"
	@echo "  build/buildroot.json"

# =========================================================
# Prepare build directory (COPY, NEVER MODIFY SUBMODULE)
# =========================================================
prepare:
	@echo "BUILDROOT_SRC = '$(BUILDROOT_SRC)'"
	@echo "BUILD_DIR     = '$(BUILD_DIR)'"
	@test -d "$(BUILDROOT_SRC)" || (echo "ERROR: buildroot submodule missing"; exit 1)
	@mkdir -p "$(BUILD_DIR)"
	@if [ ! -f "$(BUILD_DIR)/Makefile" ]; then \
		echo "→ Copying Buildroot source to build/"; \
		rsync -a --delete --exclude '.git' "$(BUILDROOT_SRC)/" "$(BUILD_DIR)/"; \
	fi

# =========================================================
# Configuration
# =========================================================
defconfig: prepare
	$(MAKE) -C "$(BUILD_DIR)" $(DEFCONFIG)
	@$(MAKE) gen-json

menuconfig: prepare
	$(MAKE) -C "$(BUILD_DIR)" menuconfig
	@$(MAKE) gen-json

build: prepare
	$(MAKE) -C "$(BUILD_DIR)"

# =========================================================
# JSON generation (OUTPUT ONLY)
# =========================================================
gen-json:
	@echo "Generating $(JSON_FILE)"
	@echo '{' > "$(JSON_FILE)"
	@echo '  "project": "EdgeWatch",' >> "$(JSON_FILE)"
	@echo '  "component": "buildroot-config",' >> "$(JSON_FILE)"
	@echo '  "bsp_version": "$(VERSION)",' >> "$(JSON_FILE)"
	@echo '  "defconfig": "$(DEFCONFIG)",' >> "$(JSON_FILE)"
	@echo '  "config_path": "build/.config"' >> "$(JSON_FILE)"
	@echo '}' >> "$(JSON_FILE)"

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
check-clean:
	@git diff --quiet || (echo "ERROR: working tree not clean"; exit 1)

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

# =========================================================
# Release (CONFIG ONLY)
# =========================================================
release: check-clean git-config check-tag-exists check-remote-tag defconfig
	@echo "→ Releasing BSP config $(TAG_NAME)"
	@git add -f "$(BUILD_DIR)/.config" "$(JSON_FILE)"
	@git commit -m "BSP config release $(TAG_NAME)"
	@git tag -a "$(TAG_NAME)" -m "EdgeWatch BSP config $(TAG_NAME)"

# =========================================================
# Push + GitHub Release (UPSTREAM SAFE)
# =========================================================
push:
	@git push --follow-tags || \
	 git push --set-upstream "$(REMOTE)" "$$(git branch --show-current)"

gh-release:
	@gh release create "$(TAG_NAME)" \
		--title "$(TAG_NAME)" \
		--notes "EdgeWatch BSP config release $(TAG_NAME)" \
		"$(BUILD_DIR)/.config" "$(JSON_FILE)"

publish: release push gh-release
	@echo "✔ BSP $(TAG_NAME) published successfully"

