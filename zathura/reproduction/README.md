# Reproducing the patched macOS Zathura setup

This directory is the complete handoff for rebuilding the Zathura setup created
on 2026-08-11. Read this document before running either script. The scripts are
fail-fast, verify pinned downloads, and do not remove the stock Homebrew tools.

## Result

- Zathura 2026.02.09 runs from `/Applications/Zathura.app`.
- The app keeps a real titled AppKit `NSWindow`, but its title, separator, and
  traffic-light buttons are hidden. `NSWindowStyleMaskFullSizeContentView`
  allows GTK content to fill the window. WindowServer—not a CALayer mask—draws
  the outer macOS window shape.
- A small app launcher always supplies `--no-titlebar`.
- VimTeX uses a dotfile shim that executes the app launcher, preserving forward
  and inverse SyncTeX support.
- The companion JankyBorders patch uses a 16-point fallback only for windows
  that report no corner radius. See `../../borders/reproduction/README.md`.

No GTK source or Homebrew GTK library is modified.

## Pinned inputs

| Input | Version / commit | SHA-256 |
| --- | --- | --- |
| Zathura source | `2026.02.09` | `ee890591608a79e75e9719054c4f29c4a611172484e93e43126651d3d5cd9477` |
| homebrew-zathura tap | `7e256f501f6aa733dc2afb9af2ebecdbb36cafc9` | Git commit |
| Native-window patch | `../patches/native-macos-window-shape.patch` | tracked here |

The tap commit supplies two prerequisite patches, applied in this order:

1. `patches/mac-integration.diff`
2. `patches/no-titlebar.diff`
3. This repository's `native-macos-window-shape.patch`

The final patch intentionally replaces the tap's borderless, hard-coded
12-point CALayer shape with a native AppKit window shape.

## Prerequisites

Install Homebrew and Xcode Command Line Tools, then install the tap's Zathura
and at least one document plugin. Building the tap formula first is a convenient
way to obtain the complete dependency set:

```sh
brew tap homebrew-zathura/zathura
brew install homebrew-zathura/zathura/zathura --with-synctex --with-no-titlebar
brew install homebrew-zathura/zathura/zathura-pdf-poppler
```

Also verify these commands exist:

```sh
command -v clang git curl patch meson ninja
pkg-config --exists girara gtk+-3.0 gtk-mac-integration-gtk3 synctex
```

Versions used for the original successful build were GTK 3.24.52, Girara
2026.07.18, gtk-mac-integration 3.0.2, and SyncTeX 2024.

## Build

Run the pinned build script from anywhere. Supply a new, nonexistent output
directory; the script refuses to overwrite one.

```sh
~/dotfiles/zathura/reproduction/build-zathura.sh \
  /private/tmp/zathura-native-build-output
```

The script downloads and verifies the source, checks out the pinned tap commit,
applies all three patches, builds, runs all upstream Meson tests, installs into
the requested output directory, and prints the resulting binary path.

## Prepare `Zathura.app`

If `/Applications/Zathura.app` does not exist, first use the tap's conversion
script. Review it before executing it because it writes under `/Applications`
and downloads the icon.

```sh
git clone https://github.com/homebrew-zathura/homebrew-zathura /private/tmp/homebrew-zathura-app
git -C /private/tmp/homebrew-zathura-app checkout 7e256f501f6aa733dc2afb9af2ebecdbb36cafc9
sed -n '1,280p' /private/tmp/homebrew-zathura-app/convert-into-app.sh
bash /private/tmp/homebrew-zathura-app/convert-into-app.sh
```

That creates the bundle metadata, icon, and plugin symlinks. Confirm that
`Contents/Resources/plugins` contains at least one valid plugin symlink.

## Install the patched app executables

Close all Zathura windows, then run:

```sh
~/dotfiles/zathura/reproduction/install-zathura-app.sh \
  /private/tmp/zathura-native-build-output/bin/zathura
```

The installer:

1. validates the app and built binary;
2. creates timestamped backups under `~/dotfiles/zathura/reproduction/backups`;
3. compiles `../zathura-app-launcher.c`;
4. installs it as `Contents/MacOS/zathura`;
5. installs the patched viewer as `Contents/MacOS/zathura-bin`;
6. ad-hoc signs both Mach-O executables; and
7. registers the app with LaunchServices.

The launcher adds `--no-titlebar` and then `exec`s `zathura-bin`. Do not replace
it with `open -a`: VimTeX's Zathura adapter needs to invoke a real executable to
retain SyncTeX and inverse-search arguments.

## Neovim / VimTeX

The tracked configuration is `../../nvim/lua/plugins/vimtex.lua`. Its relevant
portion is:

```lua
local zathura_bin = vim.fn.expand '~/dotfiles/zathura/bin'
vim.env.PATH = zathura_bin .. ':' .. vim.env.PATH
vim.g.vimtex_view_method = 'zathura'
```

The shim at `../bin/zathura` executes the app launcher. If the dotfiles checkout
is not `~/dotfiles`, update both paths. Restart Neovim after changing them.

## Verification

```sh
~/dotfiles/zathura/reproduction/verify-zathura.sh
open -na /Applications/Zathura.app --args /path/to/test.pdf
```

Visually verify that the top bar is absent and the outer window shape matches a
native titlebar-only macOS window. If Yabai is installed, confirm the new window
appears in `yabai -m query --windows` with `app` equal to `Zathura` and is not
floating unless a rule intentionally floats it.

For VimTeX, open a TeX project, run `:VimtexCompile`, and test both forward and
inverse search. In Neovim, `:echo exepath('zathura')` should point into this
repository's `zathura/bin` directory.

## Rollback

The installer prints its backup directory. To roll back, close Zathura and copy
the backed-up `zathura` and `zathura-bin` files back into
`/Applications/Zathura.app/Contents/MacOS`, restore executable permissions, and
ad-hoc sign them. Historical binaries from the original machine also live in
`../../backups/2026-08-11`, but a new machine should use its own installer
backup.

To return completely to Homebrew's app conversion, rerun the pinned
`convert-into-app.sh`; it replaces `Contents/MacOS/zathura` with the stock
Homebrew executable.

## Upgrade warning

Do not apply these patches blindly to a newer Zathura release. Re-run the build
script first; patch rejection is intentional protection. Review upstream's
current macOS integration and remove any workaround that upstream has adopted.
Homebrew upgrades can replace its CLI binary but do not automatically rebuild
the patched binary embedded in `Zathura.app`.
