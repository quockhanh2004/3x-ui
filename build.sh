#!/bin/bash

set -e

# Kiến trúc cần build
targets=(
  "linux amd64"
  "linux 386"
  "linux arm64"
  "linux arm 5"
  "linux arm 6"
  "linux arm 7"
  "linux s390x"
  "windows amd64"
)

# Xác định file entrypoint Go
ENTRYPOINT="."

# Tạo thư mục output
mkdir -p dist

for target in "${targets[@]}"; do
  read -r GOOS GOARCH GOARM <<< "$target"

  FILENAME="x-ui-${GOOS}-${GOARCH}"
  [ -n "$GOARM" ] && FILENAME="${FILENAME}v${GOARM}"

  echo "==> Building for $GOOS/$GOARCH $([ -n "$GOARM" ] && echo "v$GOARM")"

  # Thiết lập biến môi trường cross-compile
  export GOOS=$GOOS
  export GOARCH=$GOARCH
  export GOARM=$GOARM

  # Tạo thư mục tạm
  BUILD_DIR="build/${FILENAME}"
  mkdir -p "$BUILD_DIR"

  # Build binary
  OUT_BIN="$BUILD_DIR/x-ui"
  [ "$GOOS" = "windows" ] && OUT_BIN="$BUILD_DIR/x-ui.exe"
  go build -ldflags="-s -w" -o "$OUT_BIN" "$ENTRYPOINT"

  # Copy file cần thiết
  mkdir -p "$BUILD_DIR/bin"
  cp -r "bin/xray-linux-${GOARCH}" "$BUILD_DIR/bin/" 2>/dev/null || true
  cp x-ui.service "$BUILD_DIR/" 2>/dev/null || true

  # Tạo file nén
  if [ "$GOOS" = "windows" ]; then
    zip -r "dist/${FILENAME}.zip" -j "$BUILD_DIR"/*
  else
    tar -czf "dist/${FILENAME}.tar.gz" -C "$BUILD_DIR" .
  fi

  # Dọn dẹp build tạm
  rm -rf "$BUILD_DIR"
done
