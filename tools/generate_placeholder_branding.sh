#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="assets/branding"
mkdir -p "$OUT_DIR"

mk_with_magick() {
  local cmd="$1"; shift
  echo "Generating placeholders with $cmd ..."
  # Icon 1024x1024 (blue bg, white T)
  $cmd -size 1024x1024 canvas:'#1565C0' -fill white -gravity center -pointsize 480 -font DejaVu-Sans-Bold -annotate 0 'T' "$OUT_DIR/icon.png"
  # Adaptive foreground 432x432 transparent with white T
  $cmd -size 432x432 xc:none -fill white -gravity center -pointsize 300 -font DejaVu-Sans-Bold -annotate 0 'T' "$OUT_DIR/icon_foreground.png"
  # Splash 1600x1600 (green bg, white T)
  $cmd -size 1600x1600 canvas:'#2E7D32' -fill white -gravity center -pointsize 720 -font DejaVu-Sans-Bold -annotate 0 'T' "$OUT_DIR/splash.png"
  # Android 12 splash 960x960
  $cmd -size 960x960 canvas:'#2E7D32' -fill white -gravity center -pointsize 420 -font DejaVu-Sans-Bold -annotate 0 'T' "$OUT_DIR/splash_android12.png"
}

mk_with_base64() {
  # Minimal 256x256 solid color PNG fallback for all files
  echo "ImageMagick not found. Writing minimal fallback PNGs (256x256)."
  local b64='iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAIAAADTED8xAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJ
bWFnZVJlYWR5ccllPAAABFZJREFUeNrs3TEKwkAQBVCk//9s3Dg2o0V0e0gqg6Yp2pY7bL0BPn1C
M1t0g9G5gkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPh6g7z1k7YH0O0wJfXy0sUO3v2r6zq3+9fQJQEA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABg8w8BBgC8m9cG
NnqMjQAAAABJRU5ErkJggg=='
  for f in icon.png icon_foreground.png splash.png splash_android12.png; do
    echo "$b64" | base64 -d > "$OUT_DIR/$f"
  done
}

if command -v convert >/dev/null 2>&1; then
  mk_with_magick convert
elif command -v magick >/dev/null 2>&1; then
  mk_with_magick magick
else
  mk_with_base64
fi

echo "Placeholders written to $OUT_DIR"

