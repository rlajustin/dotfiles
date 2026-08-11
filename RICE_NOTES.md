# macOS rice migration notes

Target: a Rosé Pine Dawn version of gloceandotdev's Yabai setup, retaining
iTerm2 and migrating gradually.

## Baseline (2026-08-11)

- Active configs were `~/.yabairc` and `~/.skhdrc`.
- Installed: Homebrew, Yabai 7.1.25, skhd 0.3.9, Neovim, iTerm2, and an
  Inconsolata Nerd Font.
- Not detected: SketchyBar, JankyBorders, Starship, or GNU Stow.
- The old Yabai config reserved 35 px on all displays for an Ubersicht bar.
- `~/.config` is a separate, uncommitted Git repository containing application
  state. Do not replace it with somebody else's dotfiles repository.

## Stage 1 changes

- Added canonical Yabai and skhd packages under `~/dotfiles`.
- Updated the active configs to match the new direction without adding a
  symlink yet.
- Kept option+shift space/layout bindings and option+return for iTerm2.
- Added Vim-style focus/move bindings from the reference workflow.
- Changed spacing from 8 px to 10 px.
- Changed external bar reservation from `all:35:0` to `main:43:0` in
  preparation for SketchyBar.
- Added guarded Rosé Pine Dawn JankyBorders colors. It does nothing until the
  `borders` command is installed.
- Removed the automatic Ubersicht refresh from Yabai startup.

## Rollback

The exact pre-migration configs are stored in:

- `~/dotfiles/backups/2026-08-11/.yabairc`
- `~/dotfiles/backups/2026-08-11/.skhdrc`

Restore them with a normal file copy after reviewing the targets. Until then,
inspect tracked changes with:

```sh
git -C ~/dotfiles diff
```

The active files are still regular files, so they can be edited independently.
Do not create symlinks until the user has reviewed this stage.

## Planned next stage

1. Add a Rosé Pine Dawn SketchyBar package, initially without weather/API
   requirements.
2. Add an iTerm2 Rosé Pine Dawn color preset/export and font recommendations.
3. Add a safe bootstrap/check script and only then link configs.
4. Optionally add Karabiner Hyper-key bindings after confirming the user's
   preferred modifier.

## Repair: duplicate Yabai services (2026-08-11)

- Diagnosed simultaneous `com.koekeishiya.yabai` and `com.asmvik.yabai`
  LaunchAgents resizing the same BSP windows.
- Preserved the stale `com.koekeishiya.yabai.plist` in this dated backup
  directory before unloading/removing it.
- Kept `com.asmvik.yabai`, the newer service label installed in July 2026.
- Changed scripting-addition loading to non-interactive `sudo -n`, preventing
  launchd from emitting password-prompt errors when the sudoers hash is stale.

## Dotfile activation (2026-08-11)

- `~/.yabairc` is a relative symlink to `dotfiles/yabai/.yabairc`.
- `~/.skhdrc` is an absolute symlink to
  `/Users/justinkim/dotfiles/skhd/.skhdrc`; skhd could not open the initial
  relative symlink when launched by launchd.
- The files under `~/dotfiles` are now the only editable/canonical copies.
- LaunchAgent plists remain package/service metadata and are not symlinked into
  the dotfiles repository. The removed legacy Yabai plist remains backed up.

## Reference snapshot

- Repository: `gloceandotdev/dotfiles`
- Reviewed commit: `524fa9666fbc6ddf1effde1296086a4740fa29c0`
- Components worth adapting: Yabai, skhd, SketchyBar, JankyBorders, btop,
  Starship, theme switching, and wallpapers.
- Components intentionally not adopted yet: Ghostty, fish, Raycast, weather API,
  automatic shell switching, sudoers edits, and LaunchAgents.

## Bar geometry and JankyBorders (2026-08-11)

- Measured the native menu bar at 30 px through System Events.
- Confirmed Rosé Pine Dawn Simple Bar is 34 px tall.
- Replaced the hard-coded 43 px Yabai reservation with a startup calculation
  using the larger of the measured menu bar and the 34 px Simple Bar.
- With 10 px `top_padding`, tiled windows now begin at y=44 instead of y=53.
- Installed JankyBorders 1.9.0 from `felixkratz/formulae/borders`.
- Added its Rosé Pine Dawn config under `borders/.config/borders/bordersrc`.
- Left `ax_focus` at its automatic/default behavior so the service does not
  require an additional Accessibility permission.

## Simple Bar interaction repair (2026-08-11)

- Fixed Simple Bar's interaction module to use `/opt/homebrew/bin/yabai`;
  upstream click handlers otherwise fell back to missing `/usr/local/bin/yabai`.
- Dotfile-managed module: `ubersicht/simple-bar/lib/yabai.js`.
- Yabai now asks Uebersicht for a full refresh at startup so Simple Bar
  re-registers its event-driven signals after every daemon restart. Targeted
  refresh using the legacy `simple-bar-index-jsx` ID was accepted but did not
  rerun the initializer with this Uebersicht/Simple Bar combination.
- BSP, stack, and float skhd bindings now explicitly refresh the widget after
  changing layout.

## Uebersicht removal (2026-08-11)

- Abandoned Simple Bar in favor of the reference rice's SketchyBar setup.
- Preserved the meaningful `index.jsx` customization as
  `backups/2026-08-11/simple-bar-index.patch`.
- Removed Uebersicht refresh hooks from Yabai and skhd.
- Removed the temporary dotfile-managed Simple Bar interaction module.
- Restored Yabai's external bar reservation to SketchyBar's 43 px height.
- Uninstalled the Homebrew `ubersicht` cask with its login item and user data.
- Installed SketchyBar 2.24.0 and sketchybar-app-font 2.0.62.
- Imported the reference rice's SketchyBar configuration into
  `~/dotfiles/sketchybar`, fixed commands to use `/opt/homebrew`, removed the
  weather/API dependency, and made space items follow the spaces that exist.
- SF Symbols still requires a one-time interactive installer authorization;
  the cask could not complete from the non-interactive setup session.
- Added the reference `leafy-dawn.png` wallpaper to `~/dotfiles/assets` and
  applied it to every desktop.
- Expanded the desktop set from three to five spaces to match the reference
  bar's visual rhythm; SketchyBar still discovers spaces dynamically.

## Compact bar, icon font, and weather (2026-08-11)

- Reduced SketchyBar from 43 px to 34 px, item backgrounds from 30 px to 24 px,
  text/icons/padding proportionally, Yabai gaps from 10 px to 8 px, and borders
  from 5 px to 3 px.
- Replaced right-side SF Symbols with JetBrainsMono Nerd Font glyphs. The
  reference's private SF glyphs were unavailable because the SF Symbols package
  requires an interactive administrator install.
- Restored the OpenWeather item with HTTPS requests, IP-derived approximate
  location, optional explicit coordinates, timeouts, and a graceful missing-key
  state.
- `sketchybar_env` is gitignored; `sketchybar_env.example` documents the API key
  and optional coordinates without risking committing the secret.

## SketchyBar spacing refinement (2026-08-11)

- Reduced the bar to 30 px while keeping 24 px item backgrounds.
- Set Yabai top padding to 5 px: the 3 px below a centered bar item plus 5 px
  tiling padding produces the same visible 8 px gap used at the screen sides.
- Reduced default outer padding from 3 px to 2 px and tightened icon, label,
  and space-item horizontal padding.
- After visual review, increased the bar/pills to 34/28 px and text/status
  icons to 12/13 px while keeping application glyphs smaller at 12 px.
- Set bar margin to zero and removed only the first-space/far-right-date outer
  padding so edge items sit closer to the physical screen edges.

## SketchyBar space-pill padding (2026-08-11)

- Set the space pills to 10 px before the number and 14 px after the final
  application icon, with no added padding between the number and icon strip.
- Kept the first space item's outer left padding at zero so the group remains
  aligned with the physical screen edge.
- Lowered bar items by 1 px to add slightly more space above them without
  changing the 34 px bar height or Yabai's reserved area.

## Uniform window corners (2026-08-11)

- Changed JankyBorders from `style=round` to `style=uniform`.
- `round` follows each application's reported native radius, which differed
  between AppKit windows such as iTerm2 and GTK windows such as zathura.
- `uniform` uses a consistent 9 px radius for every bordered window.
- Reverted to `style=round` after visual testing: `uniform` only forces the
  border overlay to 9 px and cannot reshape the underlying application window,
  so it caused widespread mask/radius mismatches.

## Zathura macOS window repair (2026-08-11)

- Rebuilt Homebrew Zathura 2026.02.09 with the tap's supported
  `--with-no-titlebar` option; rollback is the same reinstall command without
  that option.
- Visually verified that `zathura --no-titlebar` removes the unwanted top bar
  and makes the GTK content corners agree with JankyBorders.
- Configured VimTeX with `vimtex_view_zathura_options = '--no-titlebar'`, so
  automatic PDF launches retain SyncTeX while using the corrected window.
- `~/.config/nvim` is currently a separate copy rather than a symlink to
  `~/dotfiles/nvim`; the active and tracked `vimtex.lua` files were updated
  together and should be consolidated in a later dotfile-organization pass.
- Made `/Applications/Zathura.app` the canonical GUI launch path. Its compiled
  launcher always supplies `--no-titlebar`, then replaces itself with the
  patched `zathura-bin` stored inside the same app bundle.
- VimTeX prepends `~/dotfiles/zathura/bin` to Neovim's child-process PATH. The
  shim there executes the app launcher, retaining VimTeX's Zathura-specific
  SyncTeX/inverse-search integration instead of reducing it to `open -a`.
- The pre-change app executable is backed up as
  `backups/2026-08-11/Zathura.app-zathura-original`.
- The original tap patch hard-coded Zathura's GTK content layer to a 12-point
  radius while JankyBorders fell back to 9 points, producing a visible size
  mismatch. Added `zathura/patches/windowserver-corner-radius.patch`: Zathura
  now queries the same private WindowServer corner-radius API as JankyBorders,
  uses the same 9-point fallback, and explicitly clips GTK content to the
  calculated radius. This does not modify GTK itself.
- AppKit's container-concentric corner API was considered first, but it is a
  macOS 27 API and is absent on this macOS 26.5.2 runtime and macOS 26.2 SDK.
- Rebuilt Zathura 2026.02.09 from the cached upstream source after applying the
  tap's macOS integration/titlebar patches and the dotfile-managed radius
  patch. All four upstream Meson tests passed; GTK, Girara, SQLite, and SyncTeX
  linkage remained intact.
- Installed the rebuilt executable as
  `/Applications/Zathura.app/Contents/MacOS/zathura-bin`, ad-hoc signed it, and
  verified a fresh app instance was managed and tiled by Yabai.
- The immediately previous titleless 12-point binary is backed up as
  `backups/2026-08-11/Zathura.app-zathura-bin-radius12`.

## Zathura native macOS window shape correction (2026-08-11)

- Corrected the diagnosis: the remaining difference was the application
  window's outer shape compared with native apps such as Safari, not the
  JankyBorders overlay.
- The tap's no-titlebar patch called `gtk_window_set_decorated(FALSE)` and then
  simulated rounded corners with a CALayer. Replaced that approach with a real
  titled AppKit window using `NSWindowStyleMaskFullSizeContentView`, a hidden
  transparent title bar, hidden traffic-light controls, and no manual corner
  mask. WindowServer can now choose and render the native macOS window shape.
- This change remains isolated to Zathura's Objective-C macOS bridge and does
  not modify GTK.
- Rebuilt from the same cached Zathura 2026.02.09 source; all four upstream
  tests passed with no Objective-C compiler warnings. Installed and ad-hoc
  signed the result in `Zathura.app`, then verified that Yabai tiled a fresh
  native-shape window.
- Preserved the superseded WindowServer/manual-radius build as
  `backups/2026-08-11/Zathura.app-zathura-bin-windowserver-radius`.

## JankyBorders native-shape fallback (2026-08-11)

- Measured WindowServer corner metadata for the new native-shape Zathura
  window and iTerm2: Zathura returned four zero radii while iTerm2 returned 16
  points for every corner.
- JankyBorders 1.9.0 maps a missing/zero radius to a hard-coded 9 points, which
  made Zathura's overlay visibly disagree with its macOS-rendered window shape.
- Added `borders/patches/macos26-fallback-radius.patch`, changing only the
  missing-radius fallback from 9 to 16. Applications that report a radius
  continue to use their own value under `style=round`.
- The active `bordersrc` uses the custom executable under
  `~/dotfiles/borders/bin`; the stock Homebrew binary remains unchanged for
  rollback.
- Homebrew's service starts the stock singleton before it reads `bordersrc`, so
  a custom binary named by the config can only update settings and then exits.
  Replaced that service with the dotfile-managed user LaunchAgent
  `com.justinkim.borders`, which starts the custom executable directly.

## Reproduction handoff (2026-08-11)

- Added `zathura/reproduction/README.md` with the complete ordered Zathura
  workflow, pinned versions/checksums, prerequisites, VimTeX integration,
  verification, rollback, and upgrade cautions.
- Added fail-fast scripts to download, verify, patch, build, test, install, sign,
  register, and verify the custom `Zathura.app` executables. Install-time
  backups are ignored under `zathura/reproduction/backups/`.
- Added `borders/reproduction/README.md` and a pinned rebuild/service installer
  for the companion JankyBorders missing-radius patch.
- Made `bordersrc` resolve its dotfiles checkout dynamically and made the
  LaunchAgent installer replace an existing plist symlink atomically instead of
  risking a write through that symlink.
