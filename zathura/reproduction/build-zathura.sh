#!/bin/sh
set -eu

ZATHURA_VERSION=2026.02.09
ZATHURA_SHA256=ee890591608a79e75e9719054c4f29c4a611172484e93e43126651d3d5cd9477
TAP_COMMIT=7e256f501f6aa733dc2afb9af2ebecdbb36cafc9
SOURCE_URL="https://github.com/pwmt/zathura/archive/refs/tags/${ZATHURA_VERSION}.tar.gz"
TAP_URL=https://github.com/homebrew-zathura/homebrew-zathura

if [ "$#" -ne 1 ]; then
  echo "usage: $0 OUTPUT_DIRECTORY" >&2
  exit 2
fi

output_dir=$1
case "$output_dir" in
  /*) ;;
  *) output_dir="$(pwd)/$output_dir" ;;
esac

if [ -e "$output_dir" ]; then
  echo "refusing to overwrite existing output: $output_dir" >&2
  exit 1
fi

for command_name in git curl shasum tar patch meson ninja; do
  command -v "$command_name" >/dev/null 2>&1 || {
    echo "missing required command: $command_name" >&2
    exit 1
  }
done

for package in girara gtk+-3.0 gtk-mac-integration-gtk3 synctex; do
  pkg-config --exists "$package" || {
    echo "missing pkg-config dependency: $package" >&2
    exit 1
  }
done

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
patch_file="$script_dir/../patches/native-macos-window-shape.patch"
test -f "$patch_file"

work_dir=$(mktemp -d /private/tmp/zathura-reproduction.XXXXXX)
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM

archive="$work_dir/zathura.tar.gz"
curl -fL "$SOURCE_URL" -o "$archive"
actual_sha=$(shasum -a 256 "$archive" | awk '{print $1}')
if [ "$actual_sha" != "$ZATHURA_SHA256" ]; then
  echo "Zathura checksum mismatch: $actual_sha" >&2
  exit 1
fi

git clone --quiet "$TAP_URL" "$work_dir/tap"
git -C "$work_dir/tap" checkout --quiet "$TAP_COMMIT"

source_dir="$work_dir/source"
mkdir "$source_dir"
tar -xzf "$archive" -C "$source_dir" --strip-components=1

patch -d "$source_dir" -p1 -i "$work_dir/tap/patches/mac-integration.diff"
patch -d "$source_dir" -p1 -i "$work_dir/tap/patches/no-titlebar.diff"
patch -d "$source_dir" -p1 -i "$patch_file"

meson setup "$source_dir/build" "$source_dir" \
  --prefix="$output_dir" --buildtype=release -Db_ndebug=true
ninja -C "$source_dir/build"
meson test -C "$source_dir/build" --print-errorlogs
ninja -C "$source_dir/build" install

"$output_dir/bin/zathura" --version
echo "built binary: $output_dir/bin/zathura"
