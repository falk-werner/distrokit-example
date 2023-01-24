OUT_DIR = build-cache
GEN_DIRS += $(OUT_DIR)

DOCKER_DIR = docker
GEN_DIRS += $(DOCKER_DIR)

PTXPROJ_PATH = $(shell realpath .)/ptxproj

PTXDIST_VERSION ?= 2021.02.0
PTXDIST ?= ptxdist-$(PTXDIST_VERSION)
PTXDIST_SUFFIX ?= tar.bz2
PTXDIST_URL ?= https://public.pengutronix.de/software/ptxdist/$(PTXDIST).$(PTXDIST_SUFFIX)
DOCKER_BUILDFLAGS += --build-arg 'PTXDIST_VERSION=$(PTXDIST_VERSION)'

DISTROKIT_VERSION ?= 2021.02.0
DISTROKIT ?= DistroKit-$(DISTROKIT_VERSION)
DISTROKIT_SUFFIX ?= tar.xz
DISTROKIT_URL ?= https://git.pengutronix.de/cgit/DistroKit/snapshot/$(DISTROKIT).$(DISTROKIT_SUFFIX)
DOCKER_BUILDFLAGS += --build-arg 'DISTROKIT_VERSION=$(DISTROKIT_VERSION)'

TOOLCHAIN ?= 	oselas.toolchain-2020.08.0-arm-v7a-linux-gnueabihf-gcc-10.2.1-clang-10.0.1-glibc-2.32-binutils-2.35-kernel-5.8-sanitized_2020.08.0-1-ubuntu20.04+1_amd64.deb
TOOLCHAIN_URL ?= https://debian.pengutronix.de/debian/pool/main/o/oselas.toolchain/$(TOOLCHAIN)
DOCKER_BUILDFLAGS += --build-arg 'TOOLCHAIN=$(TOOLCHAIN)'

USERID ?= $(shell id -u)
USERID := $(USERID)
DOCKER_BUILDFLAGS += --build-arg 'USERID=$(USERID)'

.PHONY: all
all: $(OUT_DIR)/distrokit-example

$(OUT_DIR)/distrokit-example: $(PTXPROJ_PATH)
$(OUT_DIR)/distrokit-example: $(DOCKER_DIR)/$(PTXDIST).$(PTXDIST_SUFFIX)
$(OUT_DIR)/distrokit-example: $(DOCKER_DIR)/$(DISTROKIT).$(DISTROKIT_SUFFIX)
$(OUT_DIR)/distrokit-example: $(DOCKER_DIR)/$(TOOLCHAIN)
$(OUT_DIR)/distrokit-example: Dockerfile Makefile | $(OUT_DIR)
	docker buildx build $(DOCKER_BUILDFLAGS) --iidfile $@ --file $< --tag distrokit-example docker

.PHONY: run
run: $(OUT_DIR)/distrokit-example
	docker run --rm -it --user "$(USERID)" -v "$(PTXPROJ_PATH):/home/user/ptxproj" distrokit-example bash

$(DOCKER_DIR)/$(PTXDIST).$(PTXDIST_SUFFIX): | $(DOCKER_DIR)
	curl -fSL -s -o $@ $(PTXDIST_URL)

$(DOCKER_DIR)/$(DISTROKIT).$(DISTROKIT_SUFFIX): | $(DOCKER_DIR)
	curl -fSL -s -o $@ $(DISTROKIT_URL)

$(DOCKER_DIR)/$(TOOLCHAIN): | $(DOCKER_DIR)
	curl -fSL -s -o $@ $(TOOLCHAIN_URL)

$(PTXPROJ_PATH): $(DOCKER_DIR)/$(DISTROKIT).$(DISTROKIT_SUFFIX)
	tar -xf $(DOCKER_DIR)/$(DISTROKIT).$(DISTROKIT_SUFFIX)
	mv $(DISTROKIT) $@
	cp rules/* $(PTXPROJ_PATH)/

$(GEN_DIRS):
	mkdir -p $@
