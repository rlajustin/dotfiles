#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
app=/Applications/Zathura.app
launcher="$app/Contents/MacOS/zathura"
viewer="$app/Contents/MacOS/zathura-bin"

plutil -lint "$app/Contents/Info.plist"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Contents/Info.plist")" = com.pwmt.zathura
test -x "$launcher"
test -x "$viewer"
test -x "$repo_root/zathura/bin/zathura"
find -L "$app/Contents/Resources/plugins" -type f -name '*.dylib' -print -quit |
  grep -q .
codesign --verify --strict --verbose=2 "$viewer"
"$launcher" --version
sh -n "$repo_root/zathura/bin/zathura"

if command -v nvim >/dev/null 2>&1; then
  nvim --headless "+lua print(vim.fn.exepath('zathura'))" +qa
fi

echo "static verification passed"
