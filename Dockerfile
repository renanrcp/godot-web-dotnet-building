ARG GIT_REPO=https://github.com/xr0gu3/godot.git
ARG GIT_BRANCH=dotnet/mono-static-linking

ARG DEV_VERSION=4.5.0.dev
ARG RELEASE_VERSION=4.5.1.rc

# Install emsdk manually is a pain, so i'll use the official image
FROM emscripten/emsdk:4.0.11 AS builder

ARG GIT_REPO
ARG GIT_BRANCH
ARG DEV_VERSION
ARG RELEASE_VERSION

# Dependencies for Godot + Mono
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

RUN git clone -b ${GIT_BRANCH} ${GIT_REPO} .

RUN mkdir nuget
RUN dotnet nuget add source /godot/nuget --name NugetSource
RUN mkdir /root/.nuget/NuGet/nuget

# Generate editor
RUN scons platform=linuxbsd target=editor \
  dev_mode=yes module_mono_enabled=yes \
  debug_symbols=no tests=no

# Generate Mono glue and sdk
RUN ./bin/godot.linuxbsd.editor.x86_64.mono --headless \
  --generate-mono-glue modules/mono/glue
RUN python3 modules/mono/build_scripts/build_assemblies.py \
  --godot-output-dir=./bin --godot-platform=linuxbsd \
  --push-nupkgs-local /godot/nuget

#  Build Web Templates
ENV EMCC_CFLAGS="-pthread" EMCC_CXXFLAGS="-pthread"
RUN scons platform=web target=template_debug \
  module_mono_enabled=yes threads=yes
RUN scons platform=web target=template_release \
  module_mono_enabled=yes threads=yes

# Copy templates to godot templates folder
RUN mkdir -p /root/.local/share/godot/export_templates/${RELEASE_VERSION}.mono
RUN mkdir -p /root/.local/share/godot/export_templates/${DEV_VERSION}.mono
RUN cp bin/godot.web.template_debug.wasm32.mono.zip /root/.local/share/godot/export_templates/${RELEASE_VERSION}.mono/web_debug.zip
RUN cp bin/godot.web.template_release.wasm32.mono.zip /root/.local/share/godot/export_templates/${RELEASE_VERSION}.mono/web_release.zip
RUN cp bin/godot.web.template_debug.wasm32.mono.zip /root/.local/share/godot/export_templates/${DEV_VERSION}.mono/web_debug.zip
RUN cp bin/godot.web.template_release.wasm32.mono.zip /root/.local/share/godot/export_templates/${DEV_VERSION}.mono/web_release.zip

# We won't use globalization in c# web for now.
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Finally we use this entrypoint to build or export the builded things.
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
