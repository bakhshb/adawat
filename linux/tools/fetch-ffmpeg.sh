#!/bin/bash
# Downloads the ffmpeg and ffprobe that ship inside the Adawat AppImage: BtbN's static GPL builds of FFmpeg 8.1, the
# same pinned build as the Windows app. BtbN deletes its daily builds after a few weeks; when the pinned one is gone,
# the newest FFmpeg 8.1 build ("latest") is used instead. The .deb and .rpm use the distribution's own ffmpeg instead.
#   linux/tools/fetch-ffmpeg.sh   → linux/build/ffmpeg/{linux-x64,linux-arm64}/{ffmpeg,ffprobe}
set -euo pipefail
cd "$(dirname "$0")/.."
TAG=autobuild-2026-10-18-13-01
VERSION=n8.1.3-18-g46d899d7a0
BASE="https://github.com/BtbN/FFmpeg-Builds/releases/download/$TAG"
LATEST="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest"
OUT=build/ffmpeg
mkdir -p "$OUT"
for pair in linux64:linux-x64 linuxarm64:linux-arm64; do
  arch=${pair%%:*}; rid=${pair#*:}
  name="ffmpeg-$VERSION-$arch-gpl-8.1"
  if [[ ! -f "$OUT/$name.tar.xz" ]] && ! curl -fL --retry 3 -o "$OUT/$name.tar.xz" "$BASE/$name.tar.xz"; then
    rm -f "$OUT/$name.tar.xz"
    name="ffmpeg-n8.1-latest-$arch-gpl-8.1"
    echo "The pinned build is gone; using $name" >&2
    curl -fL --retry 3 -o "$OUT/$name.tar.xz" "$LATEST/$name.tar.xz"
  fi
  rm -rf "$OUT/$rid" && mkdir -p "$OUT/$rid"
  tar -xJf "$OUT/$name.tar.xz" -C "$OUT/$rid" --strip-components=2 "$name/bin/ffmpeg" "$name/bin/ffprobe"
  tar -xJf "$OUT/$name.tar.xz" -C "$OUT/$rid" --strip-components=1 "$name/LICENSE.txt"
done
(cd "$OUT" && shasum -a 256 *.tar.xz > SOURCES.sha256 && cat SOURCES.sha256)
ls -la "$OUT"/linux-*/
