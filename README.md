# Godot 4 Web .NET Build Environment

## Introduction

This repository allows you to build your **Godot C#** projects for the web (experimental).
You can read more about it in this [Godot issue](https://github.com/godotengine/godot/issues/70796).

## Overview

1. The `Dockerfile` builds a **Godot Mono Linux editor** from a configurable repository and branch.
2. It also compiles the **web export templates (with threads enabled)**.
3. After building, you can run `extract.sh` or `export.sh` to extract assets or export your project.

## Docker Image

Build the image with:

```sh
docker build . -t renanrcp/godot-web-build
```

<br />

**NOTE**: If you change the image tag, update the `extract` and `export` scripts accordingly.

### Build arguments

You can customise the build via these `--build-arg` keys

| **ARG**               | **PURPOSE**                                               | **DEFAULT**                            |
| --------------------- | --------------------------------------------------------- | -------------------------------------- |
| **GIT_REPO**          | Repository from which the editor and templates are built. | `https://github.com/xr0gu3/godot.git`  |
| **GIT_BRANCH**        | Branch to compile.                                        | `dotnet/mono-static-linking`           |
| **DEV_VERSION**       | Dev version string used by the built editor.              | `4.5.dev`                              |
| **RELEASE_VERSION**   | Release version string used by the built editor.          | `4.5.1.rc`                             |
| **EDITOR_SCON_FLAGS** | Flags passed to **SCons** when building the editor.       | dev_mode=yes debug_symbols=no tests=no |
| **EXPORT_SCON_FLAGS** | Flags passed to SCons when building the export templates. | (empty)                                |

## Scripts

After building the image, two convenience scripts are available.

### Extract

Extracts the following built files to a destination folder:

- `godot.linuxbsd.editor.x86_64.mono` (the editor)
- `GodotSharp/` (directory, to use with the editor)
- `nuget/` (directory, the compiled godot nuget packages)
- `godot.web.template_release.wasm32.mono.zip`
- `godot.web.template_debug.wasm32.mono.zip`

**NOTE**: Running the templates outside the container may yield different results.

#### Usage:

```sh
./extract.sh ./path/to/output
```

#### Arguments:

| **Pos** | **Name**        | **Description**                           |
| ------- | --------------- | ----------------------------------------- |
| **1**   | **Output Path** | Where the extracted files will be placed. |

### Export

Exports a Godot C# project for the web.

#### Usage

```sh
./export.sh /path/to/project /path/to/build release index.html
```

#### Arguments

| **Pos** | **Name**             | **Description**                                 |
| ------- | -------------------- | ----------------------------------------------- |
| **1**   | **Source Path**      | Path to your Godot C# project.                  |
| **2**   | **Output Path**      | Destination for exported files.                 |
| **3**   | **Export Type**      | `release`, `debug`, or `pack`.                  |
| **4**   | **Output File Name** | e.g. `index.html`, `MyGame.html`, `MyGame.pck`. |

## Roadmap

This image targets the preview C#-for-Web workflow. Official support is expected around Godot 4.6 (subject to change).

I also experimented with 4.5 stable + C# web preview in [this branch](https://github.com/renanrcp/godot/tree/feat/add-mono-web); the game renders nothing on-screen, although scripts run (check the browser console).
