.PHONY: all info build

GIT_REF       ?= unknown
COMMIT_SHA   ?= unknown
RELEASE_TYPE ?= dev
BUILD_TS     ?= $(shell date +%Y%m%d%H%M%S)

all: info build

info:
	@echo "==== Build Info ===="
	@echo "GIT_REF       : $(GIT_REF)"
	@echo "COMMIT_SHA   : $(COMMIT_SHA)"
	@echo "RELEASE_TYPE : $(RELEASE_TYPE)"
	@echo "BUILD_TS     : $(BUILD_TS)"
	@echo "===================="

build:
	@echo "Running build test..."
	@uname -a
	@sleep 2
	@echo "Build test successful"
