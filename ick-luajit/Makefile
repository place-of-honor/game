# Fixed producer interface: ICK C builds the pinned LuaJIT source compiler.
# Both emitted frame formats retain the original LuaJIT bytecode version.
.DEFAULT_GOAL := package
ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
ICK ?=
ICK_LINK_FLAGS ?= -fno-link-libatomic
LOVE_ANDROID_SOURCE ?= $(ROOT)/build/love-android-source
LOVE_ANDROID_REVISION = 55feb38fa144f4734c26742389f279fb07d955c0
LUAJIT_TREE = 139a69a5e8a41a93ccb8bba9bae58fa26f1393c0
LUAJIT_SOURCE = $(LOVE_ANDROID_SOURCE)/love/src/jni/LuaJIT-2.1
BUILD ?= $(ROOT)/build/ick-luajit
STAGE ?= $(ROOT)/build/game
PROBE ?= $(ROOT)/build/love-probe
PACKAGE ?= $(ROOT)/dist/game.love
FRAME_FLAGS_fr1 = -DLUAJIT_DISABLE_GC64
FRAME_FLAGS_fr2 =
FRAMES = fr1 fr2
GLYPH_COMPILERS = $(addprefix $(BUILD)/glyph-,$(addsuffix /src/luajit,$(FRAMES)))
STOCK_RUNTIMES = $(addprefix $(BUILD)/stock-,$(addsuffix /src/luajit,$(FRAMES)))
BYTECODE = $(addprefix $(STAGE)/compiled/main-,$(addsuffix .ljbc,$(FRAMES)))
CHECKS = $(addprefix $(BUILD)/qualified-,$(FRAMES))
BUILD_JOBS ?= 2
ifeq ($(strip $(ICK)),)
$(error Set ICK to the qualified native ICK compiler; no compiler fallback exists)
endif
.SECONDARY:
.PHONY: check-source check-ick qualify package stage probe run FORCE
FORCE:

check-source:
	test "$$(git -C "$(LOVE_ANDROID_SOURCE)" rev-parse HEAD)" = "$(LOVE_ANDROID_REVISION)"
	test "$$(git -C "$(LOVE_ANDROID_SOURCE)" rev-parse HEAD:love/src/jni/LuaJIT-2.1)" = "$(LUAJIT_TREE)"

check-ick:
	mkdir -p "$(BUILD)"
	"$(ICK)" $(ICK_LINK_FLAGS) -std=c17 -O2 -Wall -Wextra -Werror "$(ROOT)/ick-luajit/compiler-proof.c" -o "$(BUILD)/compiler-proof"
	"$(BUILD)/compiler-proof"

$(BUILD)/glyph-%/.prepared: $(ROOT)/ick-luajit/division.patch | check-source check-ick
	mkdir -p "$(@D)"
	cp -a "$(LUAJIT_SOURCE)/." "$(@D)/"
	patch -d "$(@D)" -p1 < "$<"
	touch "$@"

$(BUILD)/stock-%/.prepared: | check-source check-ick
	mkdir -p "$(@D)"
	cp -a "$(LUAJIT_SOURCE)/." "$(@D)/"
	touch "$@"

$(BUILD)/glyph-%/src/luajit: $(BUILD)/glyph-%/.prepared
	$(MAKE) -C "$(BUILD)/glyph-$*" -j$(BUILD_JOBS) CC="$(ICK) $(ICK_LINK_FLAGS)" TARGET_LIBS=-lgcc_eh XCFLAGS="$(FRAME_FLAGS_$*)"

$(BUILD)/stock-%/src/luajit: $(BUILD)/stock-%/.prepared
	$(MAKE) -C "$(BUILD)/stock-$*" -j$(BUILD_JOBS) CC="$(ICK) $(ICK_LINK_FLAGS)" TARGET_LIBS=-lgcc_eh XCFLAGS="$(FRAME_FLAGS_$*)"

$(STAGE)/compiled/main-%.ljbc: $(ROOT)/main.lua $(BUILD)/glyph-%/src/luajit FORCE
	mkdir -p "$(@D)"
	LUA_PATH="$(BUILD)/glyph-$*/src/?.lua;;" "$(BUILD)/glyph-$*/src/luajit" -b "$<" "$@"

stage: $(BYTECODE)
	cp "$(ROOT)/ick-luajit/loader.lua" "$(STAGE)/main.lua"
	cp "$(ROOT)/conf.lua" "$(STAGE)/conf.lua"
	mkdir -p "$(STAGE)/assets"
	cp -a "$(ROOT)/assets/." "$(STAGE)/assets/"

$(BUILD)/qualified-%: $(BUILD)/glyph-%/src/luajit $(BUILD)/stock-%/src/luajit stage FORCE
	"$(BUILD)/glyph-$*/src/luajit" "$(ROOT)/ick-luajit/qualify.lua"
	! "$(BUILD)/stock-$*/src/luajit" "$(ROOT)/ick-luajit/qualify.lua" > "$(BUILD)/stock-source-rejection-$*.log" 2>&1
	grep -E 'malformed number|unexpected symbol|expected' "$(BUILD)/stock-source-rejection-$*.log"
	LUA_PATH="$(BUILD)/glyph-$*/src/?.lua;;" "$(BUILD)/glyph-$*/src/luajit" -b "$(ROOT)/ick-luajit/division.lua" "$(BUILD)/division-$*.ljbc"
	LUA_PATH="$(BUILD)/stock-$*/src/?.lua;;" "$(BUILD)/stock-$*/src/luajit" -b "$(ROOT)/ick-luajit/reference.lua" "$(BUILD)/reference-$*.ljbc"
	cmp "$(BUILD)/division-$*.ljbc" "$(BUILD)/reference-$*.ljbc"
	"$(BUILD)/stock-$*/src/luajit" "$(ROOT)/ick-luajit/check-package.lua" "$(STAGE)" "$*"
	sha256sum "$(BUILD)/glyph-$*/src/luajit" "$(BUILD)/stock-$*/src/luajit" "$(STAGE)/compiled/main-$*.ljbc" > "$@"

qualify: $(CHECKS)
	printf 'love_android_revision\t%s\nluajit_tree\t%s\nframes\tFR1,FR2\nbytecode_version\t2 unchanged\nstock_runtime_callback_tests\tPASS\nopposite_frame_rejection\tPASS\nascii_bytecode_equivalence\tPASS\nandroid_runtime_execution\tNOT_RUN\n' "$(LOVE_ANDROID_REVISION)" "$(LUAJIT_TREE)" > "$(BUILD)/receipt.tsv"

package: qualify
	mkdir -p "$$(dirname "$(PACKAGE)")"
	cd "$(STAGE)" && zip -q -9 -r "$(PACKAGE)" main.lua conf.lua assets compiled
	unzip -t "$(PACKAGE)"

probe: stage
	mkdir -p "$(PROBE)"
	cp -a "$(STAGE)/." "$(PROBE)/"
	cp "$(ROOT)/ick-luajit/loader.lua" "$(PROBE)/loader.lua"
	cp "$(ROOT)/ick-luajit/love-probe.lua" "$(PROBE)/main.lua"

run: stage
	love "$(STAGE)"

# Test the unchanged archives actually linked by love-android/Android.mk.
ABI ?=
NDK ?=
ICK_ANDROID ?=
ICK_ANDROID_FLAGS ?=
ANDROID_API ?= 21
HEADER_armeabi-v7a = arm-linux-androideabi
HEADER_arm64-v8a = aarch64-linux-android
HEADER_x86_64 = x86_64-linux-android
TARGET_armeabi-v7a = armv7a-linux-androideabi
TARGET_arm64-v8a = aarch64-linux-android
TARGET_x86_64 = x86_64-linux-android
FRAME_armeabi-v7a = fr1
FRAME_arm64-v8a = fr2
FRAME_x86_64 = fr2
RUNNER_armeabi-v7a = qemu-arm
RUNNER_arm64-v8a = qemu-aarch64
RUNNER_x86_64 =
ARCHIVE_RUNNER ?= $(RUNNER_$(ABI))
NDK_ROOT = $(NDK)/toolchains/llvm/prebuilt/linux-x86_64
ARCHIVE_PROBE = $(BUILD)/archive-probe-$(ABI)

.PHONY: qualify-archive
qualify-archive: check-source
	test -n "$(HEADER_$(ABI))"
	mkdir -p "$(BUILD)"
	test -x "$(ICK_ANDROID)"
	test -s "$(STAGE)/compiled/main-$(FRAME_$(ABI)).ljbc"
	test -f "$(LUAJIT_SOURCE)/android/$(ABI)/libluajit.a"
	"$(ICK_ANDROID)" $(ICK_ANDROID_FLAGS) --sysroot="$(NDK_ROOT)/sysroot" -nostdinc -isystem "$$("$(ICK_ANDROID)" $(ICK_ANDROID_FLAGS) -print-file-name=include)" -isystem "$(NDK_ROOT)/sysroot/usr/include" -isystem "$(NDK_ROOT)/sysroot/usr/include/$(HEADER_$(ABI))" -D__ANDROID__ -D__ANDROID_API__=$(ANDROID_API) -D__ANDROID_MIN_SDK_VERSION__=$(ANDROID_API) -DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD -I"$(LUAJIT_SOURCE)/src" -O2 -Wall -Wextra -Werror -S "$(ROOT)/ick-luajit/archive-probe.c" -o "$(ARCHIVE_PROBE).s"
	"$(NDK_ROOT)/bin/$(TARGET_$(ABI))$(ANDROID_API)-clang" -static "$(ARCHIVE_PROBE).s" "$(LUAJIT_SOURCE)/android/$(ABI)/libluajit.a" -lm -ldl -o "$(ARCHIVE_PROBE)"
	$(ARCHIVE_RUNNER) "$(ARCHIVE_PROBE)" "$(ROOT)/ick-luajit/check-package.lua" "$(STAGE)" "$(FRAME_$(ABI))"
	sha256sum "$(LUAJIT_SOURCE)/android/$(ABI)/libluajit.a" "$(ARCHIVE_PROBE)" > "$(ARCHIVE_PROBE).sha256"
