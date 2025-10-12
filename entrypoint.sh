#!/bin/sh
usage() {
  echo "Use: extract | build";
  exit 1
}

extract() {
  mkdir -p /out
  cp /godot/bin/godot.web.template_*.zip /out/
  cp /godot/bin/godot.linuxbsd.editor.x86_64.mono /out/
  cp /godot/bin/GodotSharp/ /out/ -r
  cp /godot/nuget/ /out/ -r
}

build() {
  local export_type="--export-release"

  case $2 in
    release)
      export_type="--export-release"
      ;;

    debug)
      export_type="--export-debug"
      ;;

    pack)
      export_type="--export-pack"
      ;;

    *)
      export_type="unknown"
      ;;
  esac

  if [ "$export_type" = "unknown" ]; then
    echo "Second argument must be one of: release | debug | pack"
    exit 1
  fi

  if [ -z "$3" ]; then
    echo "Third argument must be the output file name, e.g. 'MyGame.pck' or 'MyGame.html'"
    exit 1
  fi

  SRC="/workspace/src"
  OUT="/workspace/build"
  EXTRA_FLAGS=""
  mkdir -p "$OUT"
  /godot/bin/godot.linuxbsd.editor.x86_64.mono \
    --headless --path "$SRC" \
    $export_type "Web" "$OUT/$3" $EXTRA_FLAGS

  local js_file="${3%.html}.js"
  if [ -f "$OUT/$js_file" ]; then
    sed -i -E 's/DOTNET\.setup\s*\(\s*\{[^{}]*(\{[^{}]*\}[^{}]*)*\}\s*\)\s*;//g' "$OUT/$js_file"
  fi
}

case "$1" in
  extract)
      extract
      ;;
  build)
      build "$@"
      ;;
  *)
      usage
      ;;
esac
