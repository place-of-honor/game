# Division source and the LÖVE runtime

The maintained `main.lua` uses `÷`. Its producer is the LuaJIT source tree
bundled by LÖVE Android 11.5a at commit
`55feb38fa144f4734c26742389f279fb07d955c0`, tree
`139a69a5e8a41a93ccb8bba9bae58fa26f1393c0`. The narrow lexer patch accepts
U+00F7 as the existing division token, including adjacent identifiers and
numbers and reader-buffer boundaries. It preserves comments, literals,
other UTF-8 identifiers, division metamethods, and existing slash syntax.
LuaJIT's existing rejection of `//` and `÷=` remains unchanged.

The compiler is built from C by pinned ICK; the existing LÖVE engines remain
unchanged. `make -f ick-luajit/Makefile package` emits both bytecode frame
formats. Each glyph bytecode oracle must be byte-identical to its ASCII
division counterpart produced by an unpatched compiler of the same revision.

| Consumer | Bytecode frame format | Runtime acceptance |
| --- | --- | --- |
| 32-bit ARM Android release | FR1 | Actual checked-in `armeabi-v7a/libluajit.a` |
| 64-bit ARM Android release | FR2 / GC64 | Actual checked-in `arm64-v8a/libluajit.a` |
| x86_64 Android debug | FR2 / GC64 | Actual checked-in `x86_64/libluajit.a` |
| Desktop `.love` | Observed FR1 or FR2 | Runtime header selects matching chunk |

The packaged `main.lua` reads the running VM's bytecode version and frame bit,
then uses `love.filesystem.load` for the corresponding chunk. It retains the
game's VFS paths, `conf.lua`, assets, identity and callbacks. Unrecognized
bytecode versions fail explicitly. Source edits belong in the root `main.lua`;
generated chunks are ignored build outputs. Re-run the producer after edits.

The fixed Make interface accepts `ICK`, `ICK_LINK_FLAGS`,
`LOVE_ANDROID_SOURCE`, `BUILD`, `STAGE`, and `PACKAGE`. The source checkout
must match the exact revision above. `run` builds the stage and opens it with
the installed stock LÖVE. `probe` prepares a real-LÖVE drawing test. The
`qualify-archive` target accepts `ABI`, `NDK`, `ICK_ANDROID`,
`ICK_ANDROID_FLAGS`, and optionally `ARCHIVE_RUNNER`; it links the exact
engine archive with the declared NDK and runs callback and opposite-frame
rejection tests. ARM probes use QEMU, not a claimed physical Android device.

The [dated receipt](qualification-2026-10-09.tsv) records local compiler,
bytecode and runtime artifact identities. Local qualification passed both source compilers, both stock
frame runtimes, byte-for-byte bytecode controls, all three original Android
archives, callback geometry and opposite-frame rejection. Local archive
harnesses used NDK r27c API 21, while CI retains the application's existing
NDK 25.2.9519653 and separately builds its APK. Firmware/device or Play Store
acceptance is not inferred from these tests. The actual desktop LÖVE 11.5
drawing path also passed with SDL offscreen and Mesa software rendering.
PR APK checks retain the production package identity and display name.
No release is published by PR CI.

`reference.lua`, the LuaJIT patch context, and the stock-engine drawing oracle
intentionally retain ASCII division as compatibility controls.

## BACKLOG-REPAIR-02 qualification repair

The earlier 37891509152 result used GitHub's default synthetic merge checkout and mutable upload/download/Java action tags. It remains historical integration/runtime evidence and is not promoted to an explicit PR-head receipt. Both primary game source checkouts now bind the exact PR head; every remote action in the qualification and release workflows has an inspected immutable full commit pin. The unchanged upstream LÖVE Android source keeps its own fixed source pin and established foreign build path. No candidate algorithm, bytecode oracle, negative control, target ABI, signer, package identity or release trigger is changed.

The fixed Make producer requires a nonempty qualified ICK, compiles its literal-syntax proof, verifies the exact LuaJIT source tree, and routes all maintained C through that named executable. Android archive harness compilation and NDK assembly/link remain distinct declared stages; a third-party engine build is not evidence that owned C used a stock compiler. Fresh exact-head hosted desktop, both frame formats, all three real archive callbacks and APK checks must pass before merge. Physical replacement installation and store publication remain NOT_RUN.
