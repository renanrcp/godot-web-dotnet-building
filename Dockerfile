##########################
#  Builder (Linux + WASM)
##########################
FROM emscripten/emsdk:4.0.11 AS builder

# pacotes que a imagem não traz
RUN apt-get update && apt-get install -y \
  git build-essential pkg-config scons zip python3 \
  libx11-dev libxcursor-dev libxinerama-dev libxrandr-dev \
  libxi-dev libasound2-dev libpulse-dev wget gpg \
  curl python3-pip libglu1-mesa-dev libglvnd-dev fontconfig libwayland-bin

# .NET SDK 9 + workload WASM-tools
RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O pkg.deb \
  && dpkg -i pkg.deb && rm pkg.deb \
  && apt-get update && apt-get install -y dotnet-sdk-9.0
RUN dotnet workload install wasm-tools

WORKDIR /godot
RUN git clone -b feat/add-mono-web https://github.com/renanrcp/godot.git .

RUN mkdir nuget
RUN dotnet nuget add source /godot/nuget --name NugetSource
RUN mkdir /root/.nuget/NuGet/nuget

#  ── 1. Editor Linux + Mono ─────────────────────────
RUN scons platform=linuxbsd target=editor \
  dev_mode=yes module_mono_enabled=yes \
  debug_symbols=no tests=no

#  ── 2. Gera Glue + assemblies uma única vez ─────────
RUN ./bin/godot.linuxbsd.editor.x86_64.mono --headless \
  --generate-mono-glue modules/mono/glue
RUN python3 modules/mono/build_scripts/build_assemblies.py \
  --godot-output-dir=./bin --godot-platform=linuxbsd \
  --push-nupkgs-local /godot/nuget

#  ── 3. Templates Web (debug / release, multithread) ─
ENV EMCC_CFLAGS="-pthread" EMCC_CXXFLAGS="-pthread"
RUN scons platform=web target=template_debug \
  module_mono_enabled=yes threads=yes
RUN scons platform=web target=template_release \
  module_mono_enabled=yes threads=yes

# FROM debian:12-slim AS runtime

# RUN apt-get update && apt-get install -y \
#   git build-essential pkg-config scons zip python3 \
#   libx11-dev libxcursor-dev libxinerama-dev libxrandr-dev \
#   libxi-dev libasound2-dev libpulse-dev wget gpg \
#   curl python3-pip libglu1-mesa-dev libglvnd-dev fontconfig libwayland-bin

# RUN apt-get update && apt-get install -y --no-install-recommends \
#   libicu72 libfontconfig1 fonts-dejavu-core ca-certificates \
#   && rm -rf /var/lib/apt/lists/*

# RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O pkg.deb \
#   && dpkg -i pkg.deb && rm pkg.deb \
#   && apt-get update && apt-get install -y dotnet-sdk-9.0
# RUN dotnet workload install wasm-tools

# Copiamos SÓ o que precisamos:t
# COPY --from=builder /godot/bin /godot/bin
# COPY --from=builder /godot/nuget /godot/nuget
# COPY --from=builder /godot/bin/godot.web.template_debug.wasm32.mono.zip /root/.local/share/godot/export_templates/4.5.1.rc.mono/web_debug.zip
# COPY --from=builder /godot/bin/godot.web.template_release.wasm32.mono.zip /root/.local/share/godot/export_templates/4.5.1.rc.mono/web_release.zip
# COPY --from=builder /godot/bin/godot.web.template_debug.wasm32.mono.zip /root/.local/share/godot/export_templates/4.5.dev.mono/web_debug.zip
# COPY --from=builder /godot/bin/godot.web.template_release.wasm32.mono.zip /root/.local/share/godot/export_templates/4.5.dev.mono/web_release.zip

RUN echo "sadsasdaasad"
RUN ls -la bin

RUN mkdir -p /root/.local/share/godot/export_templates/4.5.1.rc.mono
RUN mkdir -p /root/.local/share/godot/export_templates/4.5.dev.mono
RUN cp bin/godot.web.template_debug.wasm32.mono.zip /root/.local/share/godot/export_templates/4.5.1.rc.mono/web_debug.zip
RUN cp bin/godot.web.template_release.wasm32.mono.zip /root/.local/share/godot/export_templates/4.5.1.rc.mono/web_release.zip
RUN cp bin/godot.web.template_debug.wasm32.mono.zip /root/.local/share/godot/export_templates/4.5.dev.mono/web_debug.zip
RUN cp bin/godot.web.template_release.wasm32.mono.zip /root/.local/share/godot/export_templates/4.5.dev.mono/web_release.zip


ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# RUN mkdir nuget
# RUN dotnet nuget add source /godot/nuget --name NugetSource
# RUN mkdir /root/.nuget/NuGet/nuget

# Script de entrada: exporta ou só extrai conforme flags
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
