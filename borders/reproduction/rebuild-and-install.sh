#!/bin/sh
set -eu

VERSION=1.9.0
SHA256=70b5bff531b67a082cc0108d88a8355ba5e7c8326285533143c185efdf21769f
SOURCE_URL="https://github.com/FelixKratz/JankyBorders/archive/refs/tags/v${VERSION}.tar.gz"
LABEL=com.justinkim.borders

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
borders_root="$repo_root/borders"
patch_file="$borders_root/patches/macos26-fallback-radius.patch"
output_binary="$borders_root/bin/borders"
source_plist="$borders_root/Library/LaunchAgents/$LABEL.plist"
installed_plist="$HOME/Library/LaunchAgents/$LABEL.plist"

for command_name in curl shasum tar patch make clang plutil launchctl; do
  command -v "$command_name" >/dev/null 2>&1 || {
    echo "missing required command: $command_name" >&2
    exit 1
  }
done

if launchctl print "gui/$(id -u)/homebrew.mxcl.borders" >/dev/null 2>&1; then
  echo "stop homebrew.mxcl.borders before installing the custom service" >&2
  exit 1
fi

work_dir=$(mktemp -d /private/tmp/jankyborders-reproduction.XXXXXX)
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM
archive="$work_dir/JankyBorders.tar.gz"
curl -fL "$SOURCE_URL" -o "$archive"
actual_sha=$(shasum -a 256 "$archive" | awk '{print $1}')
if [ "$actual_sha" != "$SHA256" ]; then
  echo "JankyBorders checksum mismatch: $actual_sha" >&2
  exit 1
fi

source_dir="$work_dir/source"
mkdir "$source_dir"
tar -xzf "$archive" -C "$source_dir" --strip-components=1
patch -d "$source_dir" -p1 -i "$patch_file"
make -C "$source_dir"

mkdir -p "$borders_root/bin" "$HOME/Library/LaunchAgents"
cp "$source_dir/bin/borders" "$output_binary"
chmod 755 "$output_binary"
codesign --force --sign - "$output_binary"
"$output_binary" --version

escaped_root=$(printf '%s' "$repo_root" | sed 's/[&|]/\\&/g')
generated_plist="$work_dir/$LABEL.plist"
sed "s|/Users/justinkim/dotfiles|$escaped_root|g" "$source_plist" > "$generated_plist"
mv -f "$generated_plist" "$installed_plist"
plutil -lint "$installed_plist"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$installed_plist"
launchctl print "gui/$(id -u)/$LABEL" | grep "$output_binary"
echo "custom JankyBorders service installed"
