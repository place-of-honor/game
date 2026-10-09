# Game

A small game project built with [LÖVE](https://love2d.org/).

## Run locally

The source uses `÷`; first build the dual-format bytecode package with the
[pinned producer](ick-luajit/README.md). From the repository directory, with
`ICK` and `LOVE_ANDROID_SOURCE` set to those qualified tools:

```sh
make -f ick-luajit/Makefile run
```

## Put it on an Android phone or tablet

No computer is needed.

1. Open this repository on GitHub.
2. Open **Releases** and choose **Draft a new release**.
3. Choose **Create new tag**, such as `v0.1.0`, targeting `main`.
4. Press **Publish release**.
5. The release will automatically get:
   - `game-v0.1.0.love` — opens in the LÖVE Android app.
   - `game-v0.1.0.apk` — a standalone Android app you can install directly.

The `.love` file is attached first; the APK appears after the Android build finishes.

APK releases use the same development signing key, so a newer release can be installed over an older one. The package id is `org.isomorphisms.game.dev`. This public development key is only for sideloaded family/testing builds, not a future Play Store release.

## Project layout

- `main.lua` — game callbacks and game code
- `conf.lua` — window and application configuration
- `assets/` — images, sounds, fonts, maps, and other game data
- `ick-luajit/` — the pinned source compiler, bytecode packaging and runtime checks

LÖVE calls `love.load` once at startup, `love.update(dt)` every frame for game logic, and `love.draw()` every frame for rendering.
