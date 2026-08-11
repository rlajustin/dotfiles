# Reproducing the companion JankyBorders patch

This patch is separate from Zathura's native AppKit-window patch. Use it only
when the native-shaped Zathura window visibly matches macOS windows but
JankyBorders draws a tighter overlay.

On the original macOS 26.5.2 machine:

- `SLSWindowIteratorGetCornerRadii` returned `16,16,16,16` for iTerm2;
- it returned `0,0,0,0` for the native-shaped GTK Zathura window; and
- JankyBorders 1.9.0 converted zero to its hard-coded 9-point fallback.

`../patches/macos26-fallback-radius.patch` changes only that missing-radius
fallback from 9 to 16. Windows that report a positive radius remain dynamic
under `style=round`.

## Build and install

Install JankyBorders once through Homebrew for its normal dependencies and man
page, but stop its service before activating the custom binary:

```sh
brew install felixkratz/formulae/borders
brew services stop felixkratz/formulae/borders
~/dotfiles/borders/reproduction/rebuild-and-install.sh
```

The script downloads and verifies JankyBorders 1.9.0, applies the patch, builds
`../bin/borders`, validates the plist, installs a user-specific LaunchAgent
generated from the tracked plist, and starts `com.justinkim.borders`.

`bordersrc` must use `style=round`. The tracked script resolves its own real
path at runtime, so it works when `~/.config/borders` is symlinked to the
repository under a different username or checkout root. The installer also
generates the LaunchAgent with the current repository path.

Do not run `bordersrc` interactively to validate it: it intentionally `exec`s a
long-running daemon. Use `sh -n` for syntax validation and manage the process
through the LaunchAgent.

## Verify

```sh
launchctl print "gui/$(id -u)/com.justinkim.borders"
ps -axo pid,command | grep '/dotfiles/borders/bin/borders'
tail -30 /private/tmp/borders_justinkim.err.log
```

There must be only one Borders process. `homebrew.mxcl.borders` must not also be
loaded.

## Rollback

```sh
launchctl bootout "gui/$(id -u)/com.justinkim.borders"
brew services start felixkratz/formulae/borders
```

Restore `bordersrc` to `/opt/homebrew/bin/borders` if it was copied rather than
symlinked. The Homebrew binary is never overwritten by this procedure.
