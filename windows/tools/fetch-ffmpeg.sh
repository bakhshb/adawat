#!/bin/zsh
# Downloads the ffmpeg and ffprobe that ship with Adawat for Windows: BtbN's GPL builds of FFmpeg 8.1
# (redistributable, no nonfree parts), pinned to one build so every release carries the same binaries. BtbN deletes its
# daily builds after a few weeks; when the pinned one is gone, the newest FFmpeg 8.1 build ("latest") is used instead.
#   windows/tools/fetch-ffmpeg.sh   → windows/build/ffmpeg/{win-arm64,win-x64}/{ffmpeg,ffprobe}.exe
set -euo pipefail
cd "$(dirname "$0")/.."
TAG=autobuild-2026-10-18-13-01
VERSION=n8.1.3-18-g46d899d7a0
BASE="https://github.com/BtbN/FFmpeg-Builds/releases/download/$TAG"
LATEST="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest"
OUT=build/ffmpeg
mkdir -p "$OUT"
for pair in winarm64:win-arm64 win64:win-x64; do
  arch=${pair%%:*}; rid=${pair#*:}
  zip="$OUT/ffmpeg-$VERSION-$arch-gpl-8.1.zip"
  if [[ ! -f "$zip" ]] && ! curl -fL --retry 3 -o "$zip" "$BASE/ffmpeg-$VERSION-$arch-gpl-8.1.zip"; then
    rm -f "$zip"
    zip="$OUT/ffmpeg-n8.1-latest-$arch-gpl-8.1.zip"
    echo "The pinned build is gone; using ${zip##*/}" >&2
    curl -fL --retry 3 -o "$zip" "$LATEST/${zip##*/}"
  fi
  rm -rf "$OUT/$rid" && mkdir -p "$OUT/$rid"
  unzip -q -j -o "$zip" "*/bin/ffmpeg.exe" "*/bin/ffprobe.exe" "*/LICENSE.txt" -d "$OUT/$rid"
done
(cd "$OUT" && shasum -a 256 *.zip > SOURCES.sha256 && cat SOURCES.sha256)
ls -la "$OUT"/win-*/
