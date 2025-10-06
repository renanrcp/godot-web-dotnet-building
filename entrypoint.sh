#!/bin/sh
set -e
case "$1" in
  extract)
      cp /godot/bin/godot.web.template_*.zip /out/
      cp /godot/bin/godot.linuxbsd.editor.x86_64.mono /out/
      cp /godot/bin/GodotSharp/ /out/ -r
      cp /godot/nuget/ /out/ -r
      ;;
  build)
      SRC="/workspace/src"
      OUT="/workspace/build"
      EXTRA_FLAGS="--embed-assemblies"
      mkdir -p "$OUT"
      /godot/bin/godot.linuxbsd.editor.x86_64.mono \
        --headless --path "$SRC" \
        --export-debug "Web" "$OUT/index.html" $EXTRA_FLAGS
      sed -i.tmp -E 's/DOTNET\.setup\s*\(\s*\{[^{}]*(\{[^{}]*\}[^{}]*)*\}\s*\)\s*;//g' "$OUT/index.js"
      ;;
  *)
      echo "Use: extract | build"; exit 1 ;;
esac
