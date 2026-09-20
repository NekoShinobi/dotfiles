# Dotfiles Sync & Cleanup Checklist

Audit of `~/.local/share/chezmoi` vs. the live EndeavourOS/Hyprland machine.
First pass 2026-09-19; **refreshed 2026-09-19 (later)** against current state.
Work top to bottom. Tick boxes as you go; delete this file when finished.

Legend: **live** = file in `~`, **source** = file in the chezmoi repo.

---

## Done since first pass ✅

- [x] `install-desktop-apps` `.osid` guard fixed → `linux-endeavouros` (uncommitted)
- [x] `hyprland.conf` + `hyprlock.conf` removed from source (Lua config is canonical)
- [x] `dot_config/ghostty/` removed from source
- [x] `dot_config/wleave/` removed from source
- [x] Noctalia migrated to `config.toml`; old `settings.json` / `colors.json` /
      `plugins.json` / `plugins/**` removed from source; live and source match
- [x] `hyprland.lua` live == source
- [x] `hyprland.lua` live `background-games` rule synced
- [x] `wppicker.sh` stray trailing `d` fixed on live
- [x] `hyprpaper.conf` deleted from live
- [x] Stale `~/.config` removed: `discord`, `awakened-poe-trade`, `quickshell`,
      `Plexamp`, `ardour8`, `WebullDesktop`

---

## 0. Safety first

- [ ] **Do not `chezmoi apply` until §3 is done.** `chezmoi status` shows `R` on
      three scripts: `01-install-hyprland-rice`, `02-install-nvidia-drivers`,
      `install-desktop-apps`. The NVIDIA one would try to replace
      `nvidia-open-dkms` with `nvidia-dkms`; the rice one would fail on bad
      elephant package names.

---

## 1. Commit what's already staged-by-deletion / untracked in the repo

`git status` currently shows ~70 deletions + 5 untracked files, none committed.

- [ ] `git add home/dot_config/hypr/hyprland.lua`
- [ ] `git add home/dot_config/hypr/noctalia/noctalia-colors.lua`
- [ ] `git add home/dot_config/hypr/notification.mp3`
- [ ] `git add home/dot_config/noctalia/config.toml`
- [ ] `git add -A home/dot_config/ghostty home/dot_config/wleave home/dot_config/noctalia home/dot_config/hypr`
      (records the deletions)
- [ ] `git add home/.chezmoiscripts/` (rice script + desktop-apps guard fix)
- [ ] Decide on `CLEANUP-CHECKLIST.md`: commit, `.gitignore`, or leave untracked.
- [ ] Commit.

---

## 2. Remaining source-repo decisions

- [ ] **`hyprland.lua` still references wleave** (lines 144–145 layerrule,
      line 191 `SUPER+SHIFT+R` → `scripts/wlogout.sh`), but wleave isn't installed and
      its config is gone. Noctalia now owns the session menu (`session_placement`
      in config.toml). Recommended: remove the layerrule + bind, delete
      `scripts/executable_wlogout.sh`. Alternative: add `wleave` to `$yaypack`.
- [ ] **`scripts/executable_wbrestart.sh`** — restarts `quickshell` with a
      `~/.config/quickshell/custom/` config; neither exists. Delete.
- [ ] **`scripts/executable_hyprlock.sh`** — 2-line wrapper for `hyprlock`; not
      bound in `hyprland.lua`; Noctalia has its own lockscreen (`lockscreen_widgets`).
      Delete, and consider dropping `hyprlock` the package too.
- [ ] `scripts/executable_KillActiveProcess.sh`, `executable_screenshot.sh`,
      `executable_wppicker.sh` — only `screenshot.sh` is bound (`SUPER+SHIFT+S`).
      Keep or prune the other two.
- [ ] **`dot_config/matugen/`** — Noctalia generates all theme templates now
      (`theme.templates` in config.toml covers btop/cava/gtk/qt/starship/wezterm/
      walker/fzf/yazi/…). Likely dead → `chezmoi forget ~/.config/matugen`.
- [ ] `dot_config/hypr/current_wallpaper` was deleted from source — confirm nothing
      references it (Noctalia handles wallpaper via `wallpaper.*` in config.toml).

---

## 3. Fix the install scripts

`home/.chezmoiscripts/linux/`

### `run_once_before_02-install-nvidia-drivers.sh.tmpl`
- [ ] `nvidia-dkms` → `nvidia-open-dkms`
- [ ] Add `lib32-nvidia-utils`, `libva-nvidia-driver`, `linux-firmware-nvidia`
- [ ] Add `set -eufo pipefail`

### `run_once_before_01-install-hyprland-rice.sh.tmpl`
- [ ] Replace `elephant-desktopapplications` / `-files` / `-clipboard` / `-calc`
      with `elephant-all-bin` (the names in the script don't exist in AUR).
- [ ] Add `greetd` to `$pacpack` (installed, needed by noctalia-greeter).
- [ ] Add packages the Hyprland config depends on:
      `grimblast-git` (screenshot.sh), `wiremix`, `impala` (float rules in
      hyprland.lua), `brightnessctl`, `playerctl`, `imv-git`, `mpvpaper`,
      `linux-wallpaperengine-git`
- [ ] Add cursor/theme: `xcursor-samtoki-bocchi-the-rock`, `win2xcur`, `xcur2png`
- [ ] Add input/locale: `fcitx5-anthy`, `fcitx5-hangul`, `fcitx5-configtool`,
      `input-remapper-git`, `imwheel`, `otf-ipafont`, `noto-fonts-cjk`
- [ ] `hyprlock` — add only if kept in §2.
- [ ] Remove duplicate `zsh` (already in `install-packages`).
- [ ] Finish or delete the commented greetd `/etc/greetd/config.toml` block.

### `run_onchange_before_install-desktop-apps.sh.tmpl`
- [ ] `jellyfin-desktop` → `jellyfin-tui`
- [ ] Add apps you want reproducible (all currently hand-installed):
      `brave-bin` `vesktop-git` `slack-desktop-wayland` `proton-mail-bin` `protonplus`
      `steam` `lutris` `wine` `mangohud` `faugus-launcher` `gale-bin` `bs-manager-git`
      `curseforge` `minecraft-launcher` `rusty-path-of-building` `unityhub` `blender`
      `reaper` `reapack` `qjackctl` `calf` `lsp-plugins-lv2` `easyeffects` `pavucontrol`
      `libreoffice-fresh` `pinta` `celluloid` `anki` `webull-desktop` `rustdesk-bin`
      `tigervnc` `apcupsd` `obs-studio` `obs-plugin-input-overlay-bin`
      `visual-studio-code-bin` `zed-preview-bin` `claude-code` `openai-codex-bin`

### `run_onchange_before_install-packages.sh.tmpl`
- [ ] Line 14: `eq .osid "linux-arch"` → `or (eq .osid "linux-arch") (eq .osid "linux-endeavouros")`
      so `fd`, `github-cli`, `fastfetch` land on EOS.
- [ ] Consider adding CLI tools your dotfiles configure that are *not* already
      chezmoi externals: `btop` `bottom` `tmux` `just` `dust` `mediainfo` `chezmoi`
      (`yazi` `neovim` `fzf` `eza` `uv` `spf` come from `.chezmoiexternal` — skip.
      `poppler-glib` `ffmpegthumbnailer` `duf` and the rest of the EOS base set
      were installed by Calamares, not you — leave them to the distro.)

### No-op scripts — finish or delete
- [ ] `run_onchange_after_install-yazi-plugins.sh.tmpl` (body commented out)
- [ ] `../run_onchange_after_configure_vscode.sh.tmpl` (body commented out)

---

## 4. Fix `.chezmoiexternal.toml.tmpl`

Externals are intentional (pin upstream releases so dotfiles behave the same on
distros with slow package updates, e.g. Ubuntu) — keep them. One fix needed:

- [ ] **`yazi` / `ya` (lines 43–53): `yazi-aarch64-unknown-linux-gnu.zip` →
      `yazi-x86_64-unknown-linux-gnu.zip`** (both `url` and `path`). Current
      `~/.local/bin/yazi` is an ARM binary (`exec format error`), so the external
      shadows pacman's `yazi` without actually working. Consider templating the
      arch with `.chezmoi.arch` the way the `fzf`/`spf` entries already do.
- [ ] (The ~660 stale `M` lines in `chezmoi status` are just externals + fonts +
      oh-my-zsh waiting for a refresh — harmless; `chezmoi apply` clears them.)

---

## 5. Re-add drifted live configs (`chezmoi re-add <path>`)

Still drifted (`chezmoi diff <path>`; `-` = live, `+` = source):

- [ ] `~/.zshrc` — live has a `# Unity CLI` block (lines 145–147) appended by the
      Unity Hub installer. Redundant: template line 7 already prepends `~/.local/bin`.
      **Delete from live**, don't re-add. (`chezmoi apply` would also remove it.)
- [ ] `~/.config/git/config` — live has `[alias] change-commits`.
- [ ] `~/.config/walker/config.toml` — live `theme = "noctalia"`; source has extra
      `clipboard`/`websearch` modules. **Merge**, then re-add.
- [ ] `~/.config/flameshot/flameshot.ini` — live has `startupLaunch=true` etc.; source
      has `useGrimAdapter=true` / `disabledGrimWarning=true`. **Merge**.
- [ ] `~/.config/starship.toml` — live has Noctalia-generated `[palettes.noctalia]`
      (40 lines). Noctalia rewrites this on every theme change → either re-add and
      accept churn, or split the palette into a separate file Noctalia owns.
- [ ] `~/.config/hypr/scripts/wppicker.sh` — trivial whitespace diff now; re-add.

---

## 6. Unmanaged files — add or ignore

### Add (`chezmoi add <path>`)
- [ ] `~/.config/hypr/hyprtoolkit.conf`
- [ ] `~/.config/walker/themes/noctalia/`
- [ ] `~/.config/hypr/wallpaper` / `wallhaven_k8x15m.jpg` — or delete; Noctalia points
      at `~/Pictures/wallhaven-rrdgp1.jpg` now.

### Generated by Noctalia — add to `.chezmoiignore` (or add & accept churn)
- [ ] `.config/hypr/noctalia.lua` — `require("noctalia")` in hyprland.lua
- [ ] `.config/hypr/noctalia/noctalia-colors.conf`
- [ ] Note: `noctalia/noctalia-colors.lua` **is** tracked (`require("noctalia/noctalia-colors")`)
      but is also generated → decide consistently: either track both `.lua` files
      or ignore both and rely on Noctalia regenerating them on first run.

### Delete from live (pre-Noctalia leftovers, reference waybar/rofi/swaync)
- [ ] `~/.config/hypr/scripts/AirplaneMode.sh`
- [ ] `~/.config/hypr/scripts/brightness.sh`
- [ ] `~/.config/hypr/scripts/volume.sh`
- [ ] `~/.config/hypr/scripts/WaybarLayout.sh`
- [ ] `~/.config/hypr/scripts/WaybarStyles.sh`
- [ ] `~/.config/hypr/scripts/waybarcava.sh`

---

## 7. Remaining stale `~/.config` entries (apps not installed)

- [ ] `Epic/` + `Unreal Engine/` (1.1 GB — no UE install found; regenerable cache)
- [ ] `go/`
- [ ] `xsettingsd/`
- [ ] KDE leftovers: `dolphinrc`, `kiorc`, `baloofileinformationrc`, `trashrc`, `session/`
- [ ] `unity-hub/` (only `logs/`; real config is `unityhub/`)
- [ ] Stray files: `tool_state`, `electron-builder.json`, `QtProject.conf`, `cef_user_data/`

---

## 8. Reclaim cache space (apps in use — clear, don't delete)

- [ ] **`~/.config/clipse/clipse.log` — still 3.4 GB.** `: > ~/.config/clipse/clipse.log`
      (and check clipse's `config.json` for a log-level setting so it doesn't regrow)
- [ ] `~/.config/Code/{Cache,CachedData,CachedExtensionVSIXs}` (~450 MB)
- [ ] Optional Electron caches: `vesktop`, `Slack`, `Proton Mail`, `BraveSoftware`,
      `bs-manager`, `exiled-exchange-2`

---

## 9. Package hygiene

- [ ] Two ChatGPT packages installed:
      `chatgpt-desktop` (26.908) → `/usr/bin/chatgpt` + `chatgpt.desktop` — **broken**;
      `chatgpt-desktop-bin` (26.727) → `/usr/bin/chatgpt-desktop` + `ChatGPT.desktop` — **works**.
      → `yay -Rns chatgpt-desktop`. The working one keeps its own menu entry.
      If you ever want it in `install-desktop-apps`, the package name is `chatgpt-desktop-bin`.
- [ ] `paru` and `yay` both installed — scripts use yay; remove paru or standardise.
- [ ] **`brightnessctl` is an orphan** (`pacman -Qdtq`) but Hyprland uses it →
      `sudo pacman -D --asexplicit brightnessctl` (and add to the rice script, §3).
- [ ] Other orphans to review: `nvm` `pnpm` `bun` `corepack` (Node toolchains —
      `.config/nvm` is a chezmoi external, so `nvm` the package may be redundant),
      `electron` `electron37` `element-web-git` `millennium-debug` `python-pygame`
      `gpsd` `wlr-randr` `qt6-wayland` `gtk-layer-shell` + build deps.
      `sudo pacman -Rns $(pacman -Qdtq)` after marking anything you want as explicit.

---

## 10. Verify

- [ ] `chezmoi diff` — only expected changes remain.
- [ ] `chezmoi status` — `R` only on scripts you've fixed and want to run.
- [ ] `chezmoi apply --dry-run --verbose`, then `chezmoi apply`.
- [ ] `yazi --version` runs (x86_64 external or pacman).
- [ ] `hyprctl reload` — no errors from `hyprland.lua`; `SUPER+SHIFT+R` does something sane
      (or is gone, per §2).
- [ ] `git status` clean; push.
