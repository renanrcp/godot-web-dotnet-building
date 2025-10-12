# Godot 4 WEB .NET Building

## Introduction

With this repo you can build your godot C# projects for web (experimental).

You can read more about in this [godot issue](https://github.com/godotengine/godot/issues/70796).

## Explanation

1. The `Dockerfile` will build a godot mono linux editor, from a specific repo and branch (and you can change that).
2. It will also compile the export templates for web (with threads).
3. After the build you can run the scripts `extract.sh` or `export.sh` to extract or export the files.

## Dockerfile/Docker Image

To build the image you can just run:

```sh
docker build . -t renanrcp/godot-web-build
```

<br />

**OBS**: You can change the image tag, but it will break the `export` and `extract` scripts.

The build process uses few build args where you can change to customize:

- **GIT_REPO** -> The repository where the docker image should build the editor and the export templates. The default value is `https://github.com/xr0gu3/godot.git`.
- **GIT_BRANCH** -> The branch where the docker image should build the editor and the export templates. The default value is `dotnet/mono-static-linking`.
- **DEV_VERSION** -> The godot dev version of the builded editor, if you change the `GIT_REPO` or `GIT_BRANCH` args to another godot version you may change this. The default value is `4.5.dev`.
- **RELEASE_VERSION** -> The godot dev version of the builded editor, if you change the `GIT_REPO` or `GIT_BRANCH` args to another godot version you may change this. The default value is `4.5.1.rc`.
- **EDITOR_SCON_FLAGS** -> Flags used by scons when build the editor. The default values is `dev_mode=yes debug_symbols=no tests=no`.
- **EXPORT_SCON_FLAGS** -> Flags used by scons when build the editor. The default values is ` `.

## Scripts

After build the docker image you will have two scripts.

### Extract

With the script `extract.sh` you can extract these builded godot files to a specific folder:

- godot.linuxbsd.editor.x86_64.mono (the editor)
- GodotSharp (folder, to use with the editor)
- nuget (folder, the compiled godot nuget packages)
- godot.web.template_release.wasm32.mono.zip (web template release with threads)
- godot.web.template_debug.wasm32.mono.zip (web debug release with threads)

**OBS**: I don't know why, but using the templates outside the image seens to have different effects.

#### Usage:

```sh
./extract.sh ./my-path/godot-extract
```

#### Arguments:

1. Output Path -> Your path where the extracted files should appear.

### Export

With the script `export.sh` you can build a godot c# project for the web, and you can choose between release, debug or pack.

#### Usage

```sh
./export.sh ./my-project-path ./my-project-export-destination-path release index.html
```

#### Arguments

1. Soruce Path -> The path for your godot c# project
2. Output Path -> The path where the exported files should appear.
3. Export Type -> The type of the export. The valid values is `release`, `debug` and `pack`.
4. File Name Output -> The file name output. It should be something like `index.html`, `MyGame.html`, `"My Game.pck"`.

## Future

This repo should be used only for the preview version, maybe official godot 4 web c# support will come in the version 4.6.

I also tried to build the templates from the 4.5 stable version + c# web preview in [this branch](https://github.com/renanrcp/godot/tree/feat/add-mono-web), but the game doesn't render nothing in screen (but scripts works, you can see in the console).
