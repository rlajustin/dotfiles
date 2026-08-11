#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
  echo "usage: $0 PATH_TO_PATCHED_ZATHURA_BINARY" >&2
  exit 2
fi

built_binary=$1
app=/Applications/Zathura.app
macos_dir="$app/Contents/MacOS"

test -x "$built_binary" || {
  echo "patched binary is not executable: $built_binary" >&2
  exit 1
}
test -d "$app/Contents/Resources/plugins" || {
  echo "prepare Zathura.app and its plugin links first; see README.md" >&2
  exit 1
}
find -L "$app/Contents/Resources/plugins" -type f -name '*.dylib' -print -quit |
  grep -q . || {
    echo "Zathura.app has no valid document plugin" >&2
    exit 1
  }

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
launcher_source="$script_dir/../zathura-app-launcher.c"
test -f "$launcher_source"

timestamp=$(date +%Y%m%d-%H%M%S)
backup_dir="$script_dir/backups/$timestamp"
mkdir -p "$backup_dir"

if [ -e "$macos_dir/zathura" ]; then
  cp -p "$macos_dir/zathura" "$backup_dir/zathura"
fi
if [ -e "$macos_dir/zathura-bin" ]; then
  cp -p "$macos_dir/zathura-bin" "$backup_dir/zathura-bin"
fi

temporary_dir=$(mktemp -d /private/tmp/zathura-app-install.XXXXXX)
trap 'rm -rf "$temporary_dir"' EXIT HUP INT TERM
clang -Wall -Wextra -Werror -O2 "$launcher_source" \
  -o "$temporary_dir/zathura-launcher"

chmod u+w "$macos_dir/zathura" 2>/dev/null || true
cp "$temporary_dir/zathura-launcher" "$macos_dir/zathura"
cp "$built_binary" "$macos_dir/zathura-bin"
chmod 755 "$macos_dir/zathura" "$macos_dir/zathura-bin"

codesign --force --sign - "$macos_dir/zathura-bin"
codesign --force --sign - "$macos_dir/zathura"
codesign --verify --strict --verbose=2 "$macos_dir/zathura-bin"

lsregister=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
"$lsregister" -f "$app"

"$macos_dir/zathura" --version
echo "backup directory: $backup_dir"
echo "installation complete; close old Zathura processes before testing"
