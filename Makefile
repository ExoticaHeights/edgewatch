# EdgeWatch top-level Makefile
# Reproducible Buildroot build wrapper

BUILDROOT_DIR := buildroot
OUT_DIR       := out/buildroot
CONFIG_FILE   := configs/qemu-aarch64/edgewatch_qemu_aarch64.config

.PHONY: all build clean distclean help

all: build

help:
	@echo "EdgeWatch Build System"
	@echo ""
	@echo "Targets:"
	@echo "  build       Apply config and build Buildroot"
	@echo "  clean       Clean build artifacts"
	@echo "  distclean   Remove all build output"
	@echo ""

build:
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

