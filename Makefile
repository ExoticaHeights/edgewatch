.PHONY: all info prepare build package release

# -----------------------------
# Inputs from CI
# -----------------------------
GIT_REF        ?= unknown
COMMIT_SHA    ?= unknown
RELEASE_TYPE  ?= dev
BUILD_TS      ?= $(shell date +%Y%m%d%H%M%S)

# -----------------------------
# Output paths
# -----------------------------
OUT_DIR       := output
LOG_DIR       := logs
ARTIFACT_NAME := build-$(RELEASE_TYPE)-$(BUILD_TS).txt

# -----------------------------
# Default target
# -----------------------------
all: info prepare build package

# -----------------------------
# Print build metadata
# -----------------------------
info:
	@echo "==== Build Info ===="
	@echo "GIT_REF       : $(GIT_REF)"
	@echo "COMMIT_SHA   : $(COMMIT_SHA)"
	@echo "RELEASE_TYPE : $(RELEASE_TYPE)"
	@echo "BUILD_TS     : $(BUILD_TS)"
	@echo "===================="

# -----------------------------
# Prepare folders
# -----------------------------
prepare:
	@mkdir -p $(OUT_DIR) $(LOG_DIR)
	@echo "Build started at $$(date)" > $(LOG_DIR)/build.log

# -----------------------------
# Simulated real build
# (replace later with BSP / APP build)
# -----------------------------
build:
	@echo "Running build steps..." | tee -a $(LOG_DIR)/build.log
	@uname -a | tee -a $(LOG_DIR)/build.log
	@sleep 2
	@echo "Build successful" | tee -a $(LOG_DIR)/build.log

# -----------------------------
# Package artifacts
# -----------------------------
package:
	@echo "Packaging artifacts..." | tee -a $(LOG_DIR)/build.log
	@echo "Release=$(RELEASE_TYPE)" > $(OUT_DIR)/$(ARTIFACT_NAME)
	@echo "Ref=$(GIT_REF)" >> $(OUT_DIR)/$(ARTIFACT_NAME)
	@echo "Commit=$(COMMIT_SHA)" >> $(OUT_DIR)/$(ARTIFACT_NAME)

# -----------------------------
# For future use (tag only)
# -----------------------------
release:
	@echo "Release target executed"
